package BCDM::Criteria::TYPE_SPECIMEN;
use strict;
use warnings;
use Carp;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::TYPE_SPECIMEN }

my $log = __PACKAGE__->_get_logger(__PACKAGE__, 'DEBUG');

# We will match against these
my @types = qw(
    type
    holotype
    lectotype
    isotype
    syntype
    paratype
    neotype
    allotype
    paralectotype
    hapantotype
    cotype
);

# This method is called statically, i.e. it is invoked on the package name with the arrow
# operator. As such, the package name is the first argument in the @_ stack.
sub _assess {
    my ( $class, $record ) = @_;
    my $matches = 0;

    # The assumpion here is merely that calling column names with the arrow somehow returns
    # the value in that cell for the focal $record. This can either come out of the database
    # or as an object created by BCDM::IO. For example, a blessed hash reference created by
    # Text::CSV from a line in a text table.
    my $rid = $record->recordid;
    for my $field ( qw(extrainfo voucher_type notes) ) {
        for my $type ( @types ) {
            if ( $record->$field =~ /$type/i ) {
                $matches++;
                $log->info("Matched $field for $type in $rid");
            }
        }
    }

    # The return value consists of two parts, here separated by commas. The first part is the
    # outcome of the ternary operator, either 0 or 1. The second part is the quoted message.
    return $matches > 0 ? 1 : 0, 'By matching /type/ against extrainfo, voucher_status, notes';
}

1;