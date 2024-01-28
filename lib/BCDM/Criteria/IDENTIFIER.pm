package BCDM::Criteria::IDENTIFIER;
use strict;
use warnings;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::IDENTIFIER }

# this tests the criterion and returns
# boolean 0/1 depending on fail/pass. In
# addition, optional notes may be returned.
# Here, the criterion to assess is:
# 'Specimen was identified by a named person'
sub _assess {
    my $package = shift;
    my $record = shift;
    # TODO implement me
    return 0, undef;
}

1;