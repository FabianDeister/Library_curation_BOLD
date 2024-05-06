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

# number of microsends to sleep before requests. Can be adjusted from outside the module via something like 500:
# $BCDM::Criteria::HAS_IMAGE::SLEEP = 500;
our $SLEEP = 500;

# endpoints to the CAOS object store. I wonder if the port number is fixed.
my $base_url  = 'https://caos.boldsystems.org:31488/api/images?processids=';
my $image_url = 'https://caos.boldsystems.org:31488/api/objects/';

# Process command line arguments
my $db_file;  # where to access database file
my $tsv_file; # using the raw TSV instead
my $log_level = 'INFO'; # verbosity level for logger
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
$log->info("Going to check for images");

# Instantiate user agent
my $ua = LWP::UserAgent->new;
$log->info("Instantiated user agent $ua");

# Connect to the database. Because there is a column `order` in the BCDM, we need to
# escape this. In SQLite that's with double quotes.
my $io;
if ( $db_file ) {
    $log->info("Going to connect to database $db_file");
    $io = BCDM::IO->new( db => $db_file );
}
elsif ( $tsv_file) {
    $log->info("Going to open TSV file $tsv_file");
    $io = BCDM::IO->new( tsv => $tsv_file );
}

# Iterate over all provided records
$io->prepare_rs;
{
	my @queue;
	while (my $record = $io->next) {

		# queue is full
		if (scalar(@queue) == 100) {
			eval { process_queue(@queue) };
			die $@ if $@;

			# flush queue, wait a bit
			@queue = ();
			usleep($SLEEP);
		}
		else {

			# add record to queue
			push @queue, $record;
		}
	}

	# process remaining records
	process_queue(@queue);
}

sub process_queue {
	my @queue = @_;

	# create GET request URL, attempt to access it
	my $process = join ',', map { $_->processid } @queue;
	my $wspoint = $base_url . $process;
	$log->debug("Attempting $wspoint");
	my $response = $ua->get($wspoint);
	$log->debug($response);

	# proceed if the HTTP::Response object signals success
	if ( $response->is_success ) {

		# fetch content
		my $json = $response->decoded_content;
		my $array_ref = decode_json $json;
		$log->debug(Dumper($array_ref));

		# iterate over the current queue, check for each record if there is an entry in the JSON response.
		# If so, print the record ID and the URL to the image. If not, print the record ID and a sad smiley.
		for my $record (@queue) {
			my $pid = $record->processid;
			my $rid = $record->recordid;
			my ($match) = grep {$_->{processid} eq $pid} @$array_ref;
			my @result = ( $rid, $BCDM::Criteria::HAS_IMAGE );
			if ($match) {
				push @result, 1, $image_url . $match->{objectid};
			}
			else {
				push @result, 0, ':-(';
			}
			print join( "\t", @result ), "\n";
		}
	}

	# die if the HTTP::Response object signals failure
	else {
		die $response->status_line;
	}
}