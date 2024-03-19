package BCDM::Criteria::HAS_IMAGE;
use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use Time::HiRes 'usleep';
use base 'BCDM::Criteria';

# number of microsends to sleep before requests. Can be adjusted from outside the module via something like 500:
# $BCDM::Criteria::HAS_IMAGE::SLEEP = 500;
our $SLEEP = 500;

# endpoints to the CAOS object store. I wonder if the port number is fixed.
my $base_url  = 'https://caos.boldsystems.org:31488/api/images?processids=';
my $image_url = 'https://caos.boldsystems.org:31488/api/objects/';

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
    usleep($SLEEP);
    my $package  = shift;
    my @record   = @_;
    my $logger   = $package->_get_logger(__PACKAGE__);
    my $process  = join ',', map { $_->processid } @record;
    my $wspoint  = $base_url . $process;
    my $uagent   = LWP::UserAgent->new;
    my @return; # return value to populate

    # going to attempt request
    $logger->debug("Attempting $wspoint");
    my $response = $uagent->get($wspoint);

    # inspect HTTP::Response
    if ( $response->is_success) {

        # fetch content
        my $json = $response->decoded_content;

        # attempt to parse JSON
        eval {
            my $array_ref = decode_json $json;

            # successfully parsed JSON list, which is not empty
            if ( scalar @$array_ref ) {

                # example: https://caos.boldsystems.org:31488/api/images?processids=BBF341-13
                my $i = 0;
                my %map = map { $_->processid => { i => $i++, retval => [ 0, 'no images' ] } } @record;
                for my $res ( @$array_ref) {
                    my $pid = $res->{processid};
                    my $oid = $res->{objectid};
                    $map{$pid}->{retval} = [ 1, $image_url . $oid ];
                    $logger->info("Image for $pid: ${image_url}${oid}");
                }

                # push into return array, sorted
                @return = map { @{ $_->{retval} } } sort { $a->{i} <=> $b->{i} } values %map;
            }
            else {

                # we will most likely never reach this. de-referencing the path in the JSON will simply error
                my $note = "empty list: no images at $wspoint";
                $logger->info($note);
                push @return, ( 0, $note ) for @record;
            }
        };
        if ( $@ ) {

            # unless $loc exists in the JSON, we will end up here
            $logger->error($@);
            push @return, ( 0, $@ ) for @record;
        }
    }
    else {
        $logger->error($response->status_line);
    }

    #
    return @return;
}

sub _batch_size { 100 }

1;
