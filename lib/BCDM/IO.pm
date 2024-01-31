package BCDM::IO;
use strict;
use warnings;
use BCDM::ORM;
use Text::CSV;
use Log::Log4perl qw(:easy);

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = INFO, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 0
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

my $log = Log::Log4perl->get_logger(__PACKAGE__);

sub new {
    my $class = shift;
    my $self  = {};
    my %args  = @_;

    # Database file was provided
    if ( $args{'db'} ) {
        my $db_file = $args{'db'};
        $log->info("Going to connect to database $db_file");
        $self->{'db'} = BCDM::ORM->connect("dbi:SQLite:$db_file", "", "", { quote_char => '"' });
    }

    # TSV file was provided
    elsif ( $args{'tsv'} ) {
        my $bold_tsv = $args{'tsv'};
        $log->info("Going to connect to TSV file $bold_tsv");
        $self->{'tsv'} = Text::CSV->new({
            sep_char         => "\t",
            binary           => 1,
            auto_diag        => 1,
            allow_whitespace => 1,
            quote_char       => undef
        });
        open my $fh, "<:encoding(utf8)", $bold_tsv or die "Could not open file '$bold_tsv': $!";
        $self->{'fh'} = $fh;
    }

    # Create and return object
    return bless $self, $class;
}

sub prepare_rs {
    my $self = shift;
    if ( $self->{'db'} ) {
        $self->{'rs'} = $self->{'db'}->resultset('Bold')->search({});
    }
    elsif ( my $tsv = $self->{'tsv'} ) {
        my $fh  = $self->{'fh'};
        my @keys = @{ $tsv->getline($fh) };
        $tsv->column_names(\@keys);
    }
}

sub next {
    my $self = shift;
    if ( $self->{'rs'} ) {
        return $self->{'rs'}->next;
    }
    elsif ( my $tsv = $self->{'tsv'} ) {
        my $fh = $self->{'fh'};
        my $row = $tsv->getline_hr($fh);
        $row->{recordid} = $. - 1;
        return BCDM::IO::TSVRecord->new($row);

    }
}

package BCDM::IO::TSVRecord;
use Carp;
use Data::Dumper;

sub new {
    my ( $class, $self ) = @_;
    return bless $self, $class;
}

sub AUTOLOAD {
    my $self = shift;

    our $AUTOLOAD;  # Contains the name of the called method
    my $method = $AUTOLOAD;
    $method =~ s/.*:://;  # Remove package name

    # Check if the key exists in the object's hash
    if ( exists $self->{$method} ) {
        return $self->{$method};
    } 
    else {
        Carp::carp Dumper($self);
        Carp::croak "No such method '$method'";
    }
}

sub DESTROY { }

1;
