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

# Check if the 'species' column contains any value
    return ($record->species =~ /^\s*$/) ? (0, "Determined from blank species column") : (1, "Determined from species column");
    }

1;
