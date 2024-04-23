use strict;
use warnings;
use JSON;
use BCDM::IO;
use BCDM::ORM;
use BCDM::Criteria;
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;
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

# Iterate over all BOLD records
$io->prepare_rs;
my @queue;
while (my $record = $io->next) {
	if ( scalar(@queue) == 100 ) {
		my $process  = join ',', map { $_->processid } @queue;
		my $wspoint  = $base_url . $process;
		my $uagent   = LWP::UserAgent->new;
		
		# going to attempt request
		$log->debug("Attempting $wspoint");
		my $response = $uagent->get($wspoint);
		$log->debug($response);

    		# inspect HTTP::Response
		if ( $response->is_success) {

		        # fetch content
		        my $json = $response->decoded_content;
			$log->debug($json);

			eval {
				my $array_ref = decode_json $json;
				$log->debug(Dumper($array_ref));
				for my $record ( @queue ) {
					my $pid = $record->processid;
					my ($match) = grep { $_->{processid} eq $pid } @$array_ref;
					if ( $match ) {
						print $record->recordid, "\t", $BCDM::Criteria::HAS_IMAGE, "\t", 1, "\t", $image_url . $match->{objectid}, "\n";
					}
					else {
                                                print $record->recordid, "\t", $BCDM::Criteria::HAS_IMAGE, "\t", 0, "\t", ':-(', "\n";
					}
				}
			};
			die $@ if $@;
		}
		@queue = ();
	}
	else {
		push @queue, $record;
	}
}
