use strict;
use warnings;
use BCDM::IO;
use BCDM::ORM;
use BCDM::Criteria;
use Getopt::Long;
use Log::Log4perl qw(:easy);

# Process command line arguments
my $db_file;  # where to access database file
my $log_level = 'INFO'; # verbosity level for logger
GetOptions(
    'db=s'  => \$db_file,
    'log=s' => \$log_level,
);

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = $log_level, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 1
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

# Instantiate logger
my $log = Log::Log4perl->get_logger('assess_taxa');
$log->info("Going to assess taxa for BAGS");

# Connect to database, prepare result set of species
$log->info("Going to connect to database $db_file");
my $orm = BCDM::ORM->connect("dbi:SQLite:$db_file", "", "", { quote_char => '"' });
my $taxa = $orm->resultset('Taxa')->search({ level => 'species', name => { '!=' => '' } });
$log->info("Will assess " . $taxa->count . " species");

# Iterate over taxa
print join("\t", 'taxonid', 'name', 'level', 'kingdom', 'grade'), "\n"; # header
while (my $taxon = $taxa->next) {
    my $name = $taxon->name;
    my $taxonid = $taxon->taxonid + 1; # ALERT ALERT ALERT TODO why is this.
    $log->info("Assessing taxon $name ($taxonid)");

    # Get all records for this taxon
    my $records = $orm->resultset('Bold')->search({ taxonid => $taxonid });

    # Count records
    my $record_count = $records->count;
    $log->info("Found $record_count records for taxon $name");

    # Fetch distinct BINs
    my $bins = $records->search({}, { columns => 'bin_uri', distinct => 1 });
    my $bin_count = $bins->count;
    $log->info("Found $bin_count distinct BINs for taxon $name");

    # Iterate over bins, check if bin is shared among taxa
    my $is_shared = 0;
    while(my $bin_uri = $bins->next) {
        my $uri = $bin_uri->bin_uri;
        $log->info("Assessing bin $uri");
        my $bin_records = $orm->resultset('Bold')->search({ bin_uri => $uri });
        my $bin_taxa = $bin_records->search({}, { columns => 'taxonid', distinct => 1 });
        my $bin_taxon_count = $bin_taxa->count;
        $log->info("Found $bin_taxon_count taxa sharing bin $uri");

        # If this is anything other than zero, there is a problem
        $is_shared++ if $bin_taxon_count > 1;
    }

    # Now we can report the BAGS assessment.

    # Grade A means: >10 specimens, in 1 unshared BIN
    if ($record_count > 10 && $bin_count == 1 && !$is_shared) {
        $log->info("Taxon $name is BAGS grade A");
        prepare_output($taxon, 'A');
    }

    # Grade B means: 3-10 specimens, in 1 unshared BIN
    elsif ( 3 <= $record_count < 10 && $bin_count == 1 && !$is_shared) {
        $log->info("Taxon $name is BAGS grade B");
        prepare_output($taxon, 'B')
    }

    # Grade C means more than 1 bin
    elsif( $bin_count > 1 && !$is_shared ) {
        $log->info("Taxon $name is BAGS grade C");
        prepare_output($taxon, 'C');
    }

    # Grade D means <3 specimens in 1 bin
    elsif( $record_count < 3 && $bin_count == 1 && !$is_shared ) {
        $log->info("Taxon $name is BAGS grade D");
        prepare_output($taxon, 'D');
    }

    # Grade E means bin sharing
    elsif( $is_shared > 0 ) {
        $log->info("Taxon $name is BAGS grade E");
        prepare_output($taxon, 'E');
    }

    # This shouldn't happen
    else {
        $log->warn("Taxon $name does not match any of the BAGS grades");
        prepare_output($taxon, 'WARN')
    }
}

sub prepare_output {
    my ( $record, $grade ) = @_;
    my $taxonid = $record->taxonid;
    my $name    = $record->name;
    my $level   = $record->level;
    my $kingdom = $record->kingdom;
    print join("\t", $taxonid, $name, $level, $kingdom, $grade), "\n";
}