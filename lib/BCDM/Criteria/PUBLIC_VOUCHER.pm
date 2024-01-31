package BCDM::Criteria::PUBLIC_VOUCHER;
use strict;
use warnings;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::PUBLIC_VOUCHER }

my @neg = (
    'DNA',
    'e-vouch',
    'private',
    'no voucher specimen',
    'no voucher, tissue only',
    'unvouchered'
);

my @pos = qw(
    herb
    museum
    registered
    type
);

my $log = __PACKAGE__->_get_logger(__PACKAGE__, 'DEBUG');

# this tests the criterion and returns
# boolean 0/1 depending on fail/pass. In
# addition, optional notes may be returned.
# Here, the criterion to assess is:
# 'Specimen is vouchered in a public collection'
# This will involve substring matching in
# the voucher_type column. There are many
# distinct values but there is some
# regularity to them.
sub _assess {
    my $package = shift;
    my $record = shift;
    my $method = $record->voucher_type;
    my $id = $record->recordid;

    # Check positive matches
    my @mp;
    for my $pattern ( @pos ) {
         if ( $method =~ /$pattern/ ) {
            push @mp, $pattern;
            $log->info("Positive match for $id: $pattern")
        }
    }

    # Check negative matches
    my @mn;
    for my $pattern ( @neg ) {
         if ( $method =~ /$pattern/ ) {
            push @mn, $pattern;
            $log->info("Negative match for $id: $pattern")
        }
    }

    # Return result
    return @mp > @mn ? 1 : 0, "Based on pos > neg matches (@mp > @mn)";
}

1;