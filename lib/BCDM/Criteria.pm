package BCDM::Criteria;
use strict;
use warnings;
use Carp 'croak';
use BCDM::ORM;

our $SPECIES_ID=1;
our $TYPE_SPECIMEN=2;
our $SEQ_QUALITY=3;
our $PUBLIC_VOUCHER=4;
our $HAS_IMAGE=5;
our $IDENTIFIER=6;
our $ID_METHOD=7;
our $COLL_DETAILS=8;

# input is a bold table record and a
# string version of the name, e.g. 'SPECIES_ID'
sub assess {
    my ( $record, $criterion ) = @_;

    # attempt to load the implementation of the criterion
    my $package = __PACKAGE__ . '::' . uc($criterion);
    eval { require $package };
    if ( defined $@ ) {
        croak "Unknown criterion $criterion: $@";
    }

    # delegate the assessment
    my ( $status, $notes ) = $package->_assess($record);

    # insert into table
    my $criterionid = $package->_table;
    my $result = $schema->resultset('BoldCriteria')->find_or_create({
        criterion_id => $criterionid,
        record_id    => $recordid->recordid
    });
    $result->update({ status => $status, notes => $notes });
}

1;