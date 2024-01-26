use strict;
use warnings;
use lib '../../lib';
use BCDM::ORM;
use Getopt::Long;
use Log::Log4perl qw(:easy);

# Process command line arguments
my $targetlist; # location of ;-separated target list
my $db_file;    # where to create database file
my $log_level = 'INFO'; # verbosity level for logger
my $project = 'BGE-BIOSCAN'; # name of the project/target
GetOptions(
    'list=s'    => \$targetlist,
    'db=s'      => \$db_file,
    'log=s'     => \$log_level,
    'project=s' => \$project,
);

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = $log_level, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 0
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

# Instantiate logger
my $log = Log::Log4perl->get_logger('load_targetlist');

# Connect to the database
$log->info("Going to connect to database $db_file");
my $schema = BCDM::ORM->connect("dbi:SQLite:$db_file");

# Start reading the target list
$Log->info("Going to read target list $targetlist for $project");
open my $fh, '<', $targetlist or die $!;
while(<$fh>) {
    chomp;

    # Parse the line, instantiate a Target record with the
    # canonical name and the project code
    my ( $canonical, @synonyms ) = split /\s*;\s*/, $_;
    my $target = $schema->resultset('Target')->create({
        name        => $canonical,
        targetlist  => $project
    });

    # Iterate over the synonyms and instantiate Synonym
    # records that have the foreign key
    for my $syn ( @synonyms ) {
        $schema->resultset('Synonym')->create({
            name     => $syn,
            targetid => $target->id
        });
    }

    # TODO Matching against taxa table goes here

    # Report progress
    $log->info("Processed record " . $target->id) unless $target->id % 1000;
}



