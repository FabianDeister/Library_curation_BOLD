package BCDM::Criteria::TYPE_SPECIMEN;
use strict;
use warnings;
use Carp;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::TYPE_SPECIMEN }

sub _assess {
    croak __PACKAGE__ . " not implemented yet";
}

1;
