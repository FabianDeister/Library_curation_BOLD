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
# Check if the species field contains "sp." or is empty
    if ($record->species =~ /^\s*$/ || $record->species eq 'sp.') {
        return 0, "Species column is empty or contains 'sp.'";
    }

# If species field is not empty and doesn't contain 'sp.', the criterion passes
    return 1, "Determined from species column";
}
    
1;
