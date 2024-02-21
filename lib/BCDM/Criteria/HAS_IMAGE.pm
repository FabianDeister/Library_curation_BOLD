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
    my $logger   = $package->_get_logger;
    my $process  = $record->processid;
    my $wspoint  = $base_url . $process;
    my $uagent   = LWP::UserAgent->new;

    # going to attempt request
    $logger->debug("Attempting $wspoint");
    my $response = $uagent->get($wspoint);

    # inspect HTTP::Response
    if ( $response->is_success) {

        # parse content
        $logger->debug("Request was successful");
        my $json = $response->decoded_content;
        $logger->debug($json);
        my $hash = decode_json $json;

        eval {

            # traverse serialized JSON structure, should always exist up to $process
            my $p = $hash->{bold_records}->{records}->{$process};
            if ( exists $p->{specimen_imagery} ) {
                my $loc = $p->{specimen_imagery}->{media}->[0]->{image_file};
                $logger->info($loc);
                return 1, $loc;
            }
            else {

                # we will most likely never reach this. de-referencing the path in the JSON will simply error
                my $note = 'no specimen_imagery in JSON';
                $logger->debug($note);
                return 0, $note;
            }
        };
        if ( $@ ) {

            # unless $loc exists in the JSON, we will end up here
            $logger->error($@);
            return 0, $@;
        }
    }
    else {
        $logger->error($response->status_line);
    }
}

1;
