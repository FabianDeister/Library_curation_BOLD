package BCDM::Criteria::HAS_IMAGE;
use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use base 'BCDM::Criteria';

my $base_url = 'http://boldsystems.org/index.php/API_Public/specimen?format=json&ids=';

# http://boldsystems.org/index.php/API_Public/specimen?format=json&ids=ABINP144-21

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::HAS_IMAGE }

# this tests the criterion and returns
# boolean 0/1 depending on fail/pass. In
# addition, optional notes may be returned.
# Here, the criterion to assess is:
# 'Specimen is photographed'
# For this particular case, the BCDM does 
# not list whether there is an image. The
# way to find out is to hit the API as follows:
# http://boldsystems.org/index.php/API_Public/specimen?ids=${processid}&format=json
# and then traversing the returned JSON to look for an image. Probably an 
# expensive operation!
sub _assess {
    my $package  = shift;
    my $record   = shift;
    my $process  = $record->processid;
    my $wspoint  = $base_url . $process;
    my $uagent   = LWP::UserAgent->new;
    my $response = $uagent->get($wspoint);
    if ( $response->is_success) {
        my $json = $response->decoded_content;
        my $hash = decode_json $json;

        eval {
            my $loc = $hash->{bold_records}->{records}->{$process}->{specimen_imagery}->{media}->[0]->{image_file};
            if ( $loc ) {
                return 1, $loc;
            }
            else {
                return 0, 'no image URL in JSON';
            }
        };
        if ( $@ ) {
            return 0, $@;
        }
    }
    else {
        die $response->status_line;
    }
}

1;
