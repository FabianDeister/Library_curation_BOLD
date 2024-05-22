package BCDM::BAGS;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use BCDM::Criteria;

our $AUTOLOAD;
my $log = BCDM::Criteria->get_logger('BAGS');

sub new {
    my ( $class, $taxon ) = @_;
    my $self = {
        'taxon'   => undef, # BCDM::ORM::Result::Taxa
        'bins'    => [],
        'records' => [],
    };
    bless $self, $class;
    $self->taxon($taxon);
    return $self;
}

sub taxon {
    my ( $self, $taxon ) = @_;
    if ( defined $taxon ) {
        my ( $id, $name, $level, $kingdom ) = map { $taxon->$_ } qw( taxonid name level kingdom );
        $log->info("Setting $level $name ($id) from kingdom $kingdom");
        $self->{'taxon'} = $taxon;

        # Get all barcodes for this taxon. Possibly this might be the point where we
        # add a search predicate to filter on top 3 quality level.
        my $orm = $taxon->result_source->schema;
        $self->records( [ $orm->resultset('Bold')->search({ taxonid => $id + 1, marker_code => 'COI-5P' })->all ] );
        $log->info("Found " . $self->n_records . " records for $name");

        # Get all distinct, defined BINs for this taxon's records
        $self->bins( [ keys %{{ map { $_ => 1 } grep { $_ } map { $_->bin_uri } @{ $self->records } }} ] );
        $log->info("Found " . $self->n_bins . " distinct BINs for $name");
    }
    return $self->{'taxon'};
}

sub n_records { scalar @{ shift->records } }

sub n_bins { scalar @{ shift->bins } }

sub grade {
    my $self = shift;

    # If this list's size is greater than zero, then the taxon shares a BIN with another taxon
    my $is_shared = scalar($self->sharing_taxa);

    # Grade A means: >=10 specimens, in 1 unshared BIN
    if ( $self->n_records >= 10 && $self->n_bins == 1 && !$is_shared ) {
        $log->info($self->taxon->name . " is BAGS grade A");
        return 'A';
    }

    # Grade B means: 3-9 specimens, in 1 unshared BIN
    elsif ( 3 <= $self->n_records < 10 && $self->n_bins == 1 && !$is_shared ) {
        $log->info($self->taxon->name . " is BAGS grade B");
        return 'B';
    }

    # Grade C means: more than 1 unshared BIN
    elsif ( $self->n_bins > 1 && !$is_shared ) {
        $log->info($self->taxon->name . " is BAGS grade C");
        return 'C';
    }

    # Grade D means: <3 specimens, in 1 unshared BIN
    elsif ( $self->n_records < 3 && $self->n_bins == 1 && !$is_shared ) {
        $log->info($self->taxon->name . " is BAGS grade D");
        return 'D';
    }

    # Grade E means: BIN sharing
    elsif ($is_shared) {
        $log->info($self->taxon->name . " is BAGS grade E");
        return 'E';
    }

    # This shouldn't happen
    else {
        $log->warn("Could not determine BAGS grade for " . $self->taxon->name);
        return 'F';
    }
}

sub taxa_sharing_bin {
    my ( $self, $bin ) = @_;
    my $orm = $self->taxon->result_source->schema;

    # Get all records with the same BIN URI
    my $bin_records = $orm->resultset('Bold')->search({ bin_uri => $bin });
    $log->info("Assessing " . $bin_records->count . " records sharing bin $bin");

    # Get all distinct taxon identifications for the records matching the BIN URIs
    my %seen;
    while ( my $record = $bin_records->next ) {
        my $name = $record->identification;
        $seen{$name}++;
    }

    # Remove self and lineage
    delete $seen{$_->name} for $self->taxon->lineage;

    # Report and return the names
    my @names = keys %seen;
    $log->info("Found " . scalar(@names) . " other taxa sharing " . $self->n_bins . " distinct BINs");
    return @names;
}

sub sharing_taxa {
    my $self = shift;
    my $orm  = $self->taxon->result_source->schema;

    # Get all the records with the same BIN URIs
    my $bin_records = $orm->resultset('Bold')->search({ bin_uri => { -in => $self->bins } });
    $log->info("Assessing " . $bin_records->count . " records sharing " . $self->n_bins . " distinct BINs");

    # Get all distinct taxon identifications for the records matching the BIN URIs
    my %seen;
    while ( my $record = $bin_records->next ) {
        my $name = $record->identification;
        $seen{$name}++;
    }

    # Remove self and lineage
    delete $seen{$_->name} for $self->taxon->lineage;

    # Report and return distinct names
    my @names = keys %seen;
    $log->info("Found " . scalar(@names) . " other taxa sharing " . $self->n_bins . " distinct BINs");
    return @names;
}

sub AUTOLOAD {
    my ( $self, $arg ) = @_;
    my $method = $AUTOLOAD; # Contains the fully qualified name of the called method
    $method =~ s/.*:://;    # Remove package name

    # Check if the name exists in the object's hash as defined in the constructor
    if ( exists $self->{$method} ) {

        # If an argument is passed, set the value of the key in the object's hash
        if ( defined $arg ) {
            $self->{$method} = $arg;
        }
        return $self->{$method};
    }
    elsif ( $method =~ /^[A-Z]+$/ ) {
        return;
    }
    else {
        Carp::carp Dumper($self);
        Carp::croak "No such method '$method'";
    }
}

1;
