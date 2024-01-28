package BCDM::Criteria::SPECIES_ID;
use strict;
use warnings;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::SPECIES_ID }

# this tests the criterion and returns
# boolean 0/1 depending on fail/pass. In
# addition, optional notes may be returned.
# Here, the criterion to assess is:
# 'Specimen was identified to species rank'
sub _assess {
    my $package = shift;
    my $record = shift;
    return $record->species eq 'None' ? 0 : 1, "Determined from species column, not identification_rank";
}

1;