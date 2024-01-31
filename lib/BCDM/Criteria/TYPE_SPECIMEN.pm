package BCDM::Criteria::TYPE_SPECIMEN;
use strict;
use warnings;
use Carp;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::TYPE_SPECIMEN }

my $log = __PACKAGE__->_get_logger(__PACKAGE__, 'DEBUG');

sub _assess {
    my ( $class, $record ) = @_;
    my $matches = 0;
    my $rid = $record->recordid;
    for my $field ( qw(extrainfo voucher_status notes) ) {
        if ( $record->$field =~ /type/ ) {
            $matches++;
            $log->info("Matched $field in $rid");
        }
    }
    return $matches > 0 ? 1 : 0, 'By matching /type/ against extrainfo, voucher_status, notes';
}

1;
