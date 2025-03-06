use strict;
use warnings;
use JSON;
use BCDM::IO;
use BCDM::ORM;
use BCDM::Criteria;
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;
use Time::HiRes qw(usleep);
use Log::Log4perl qw(:easy);

# Delay to prevent overloading the API (adjustable)
our $SLEEP = 500;

# New API Endpoints
my $query_api  = 'https://portal.boldsystems.org/api/query?query=';
my $image_api  = 'https://portal.boldsystems.org/api/images/';

# Process command line arguments
my $db_file;
my $tsv_file;
my $log_level = 'INFO';
my $persist   = 0;
GetOptions(
    'db=s'       => \$db_file,
    'tsv=s'      => \$tsv_file,
    'log=s'      => \$log_level,
    'persist'    => \$persist,
);

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = $log_level, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 1
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

# Instantiate logger
my $log = Log::Log4perl->get_logger('assess_criteria');
$log->info("Starting image assessment...");

# Instantiate user agent
my $ua = LWP::UserAgent->new;
$log->info("Initialized user agent");

# Connect to the database or TSV
my $io;
if ($db_file) {
    $log->info("Connecting to database $db_file");
    $io = BCDM::IO->new(db => $db_file);
}
elsif ($tsv_file) {
    $log->info("Opening TSV file $tsv_file");
    $io = BCDM::IO->new(tsv => $tsv_file);
}

# Iterate over all provided records
$io->prepare_rs;
while (my $record = $io->next) {
    eval { process_record($record) };
    if ($@) {
        $log->error("Error processing record: $@");
    }
    usleep($SLEEP);
}

sub process_record {
    my ($record) = @_;
    my $pid = $record->processid;
    my $rid = $record->recordid;

    # Query API for a single processid
    my $query_url = $query_api . "ids:processid:" . $pid . "&extent=limited";
    $log->debug("Querying BOLD API: $query_url");

    my $query_response = $ua->get($query_url);
    unless ($query_response->is_success) {
        die "Query API failed: " . $query_response->status_line . "\nResponse: " . $query_response->decoded_content;
    }

    my $query_json = decode_json($query_response->decoded_content);
    my $query_id   = $query_json->{query_id} or die "No query_id returned!";

    # Fetch images using the query_id
    my $image_url = $image_api . $query_id . '?max_images=-1';
    $log->debug("Fetching images: $image_url");

    my $image_response = $ua->get($image_url);
    unless ($image_response->is_success) {
        die "Image API failed: " . $image_response->status_line . "\nResponse: " . $image_response->decoded_content;
    }

    my $image_json = decode_json($image_response->decoded_content);
    my $image_data = $image_json->{images} || [];

    my ($match) = grep { $_->{processid} eq $pid } @$image_data;
    my @result = ($rid, $BCDM::Criteria::HAS_IMAGE);

    if ($match) {
        push @result, 1, $match->{image_url};
    } else {
        push @result, 0, 'No image found';
    }
    print join("\t", @result), "\n";
}
