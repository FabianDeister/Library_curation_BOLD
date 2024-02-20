use strict;
use warnings;
use BCDM::ORM;
use Getopt::Long;
use Log::Log4perl qw(:easy);

# Process command line arguments
my $targetlist; # location of ;-separated target list
my $db_file;    # where to create database file
my $log_level   = 'INFO'; # verbosity level for logger
my $project     = 'BGE-iBOL-Europe'; # name of the project/target
my $taxon_level = 'species'; # what level we're using
my $kingdom     = 'Animalia'; # default is animals/COI-5P
GetOptions(
    'list=s'    => \$targetlist,
    'db=s'      => \$db_file,
    'log=s'     => \$log_level,
    'project=s' => \$project,
    'taxon=s'   => \$taxon_level,
    'kingdom=s' => \$kingdom,
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
$log->info("Going to read target list $targetlist for $project");
open my $fh, '<', $targetlist or die $!;
while(<$fh>) {
    chomp;
    next if /^$/;

    # Parse the line, instantiate a Target record with the
    # canonical name and the project code
    my ( $canonical, @synonyms ) = split /\s*;\s*/, $_;
    $log->debug("Instantiating target record for '$canonical'");
    my $target = $schema->resultset('Target')->create({ name => $canonical, targetlist => $project });
    $target->insert;

    # Iterate over the synonyms and instantiate Synonym
    # records that have the foreign key to the Target
    my %syn;
    for my $syn ( @synonyms ) {
        $log->debug("Instantiating synonym record for '$syn'");
        $syn{$syn} = $schema->resultset('Synonym')->create({ name => $syn, targetid => $target->targetid });
        $syn{$syn}->insert;
    }

    # attempt map against taxa
    my $taxa  = $schema->resultset('Taxa');
    my $taxon = $taxa->search({ level => 'species', name => $canonical, kingdom => $kingdom })->single;
    if ( not defined $taxon ) {
        SYNONYM: for my $syn ( @synonyms ) {
            my $t = $taxa->search({ level => 'species', name => $syn, kingdom => $kingdom })->single;
            if ( defined $t ) {
                $taxon = $t;
                last SYNONYM;
            }
        }
    }

    # create target link
    if ( defined $taxon ) {
        $schema->resultset('BoldTarget')->create({
            taxonid  => $taxon->taxonid,
            targetid => $target->targetid,
        })->insert;
        $log->info("Linking target $target to taxon $taxon ($canonical)");
    }
    else {
        $log->warn("No target link for $canonical");
    }

    # Report progress
    $log->info("Processed record " . $target->id) unless $target->id % 1000;
}

# delete from synonyms;
# delete from  bold_targets;
# delete from targets;

