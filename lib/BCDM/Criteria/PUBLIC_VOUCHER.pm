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
    'privat',
    'no voucher',
    'unvouchered',
    'destr',
    'lost',
    'missing',
    'no specimen',
    'none',
    'not vouchered',
    'person',
    'Photo Voucher Only',
    'not registered',
);

my @pos = qw(
    herb
    museum
    registered
    type
    national
    CBG
    INHS
    deposit
    harbarium
    hebarium
    holot
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
    my $result = undef;
    if ( @mp ) {
        $result = 1;
    }
    elsif ( @mn ) {
        $result = 0;
    }
    return $result, "Based on whether has positive (@mp)/1, negative (@mn)/0, or no matches (null)";
}

1;
