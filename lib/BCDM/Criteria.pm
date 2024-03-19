package BCDM::Criteria;
use strict;
use warnings;
use Carp 'croak';
use BCDM::ORM;
use Module::Load;
use Log::Log4perl qw(:easy);

our $SPECIES_ID=1;
our $TYPE_SPECIMEN=2;
our $SEQ_QUALITY=3;
our $PUBLIC_VOUCHER=4;
our $HAS_IMAGE=5;
our $IDENTIFIER=6;
our $ID_METHOD=7;
our $COLLECTORS=8;
our $COLLECTION_DATE=9;
our $COUNTRY=10;
our $SITE=11;
our $COORD=12;

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = INFO, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 1
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

# input is a bold table record and a
# string version of the name, e.g. 'SPECIES_ID'
{
    my @queue;
    sub assess {
        my ($self, %args) = @_;

        # delegate the assessment
        if ( scalar(@queue) == $self->_batch_size ) {
            my @result = $self->_assess(@queue);
            while( @result ) {
                my $status = shift @result;
                my $notes  = shift @result;
                $args{handler}->( $status, $notes );
            }
            @queue = ();
        }
        else {
            push @queue, $args{record};
        }
    }
}

sub persist {
    my ( $self, %args ) = @_;
    my $cid    = $self->_criterion;
    my $record = $args{'record'};
    my $status = $args{'status'};
    my $notes  = $args{'notes'};
    my $schema = $record->result_source->schema;
    my $result = $schema->resultset('BoldCriteria')->find_or_create({
        criterionid => $cid,
        recordid    => $record->recordid,
    });
    $result->update({ status => $status, notes => $notes });
}

sub _get_logger {
    my ( $self, $name ) = @_;
    return Log::Log4perl->get_logger($name);
}

sub load_criterion {
    my ( $self, $criterion ) = @_;
    my $package = __PACKAGE__ . '::' . uc($criterion);
    eval { load $package };
    if ( $@ ) {
        croak "Unknown criterion $criterion: $@";
    }
    return $package;
}

sub _batch_size { 1 }

1;
