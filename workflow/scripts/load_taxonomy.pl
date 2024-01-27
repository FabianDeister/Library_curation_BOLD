use strict;
use warnings;
use BCDM::ORM;
use Data::Dumper;
use Getopt::Long;
use Log::Log4perl qw(:easy);

# Configure Data::Dumper for terse representation
$Data::Dumper::Terse = 1;    # Avoids variable name being printed
$Data::Dumper::Indent = 0;   # No indentation (single line output)
$Data::Dumper::Useqq = 1;    # Use double quotes for string values

# Levels in the BOLD taxonomy
my @levels = qw[
    kingdom
    phylum
    class
    order
    family
    subfamily
    genus
    species
    subspecies
];

# Kingdoms in the BOLD taxonomy
my @kingdoms = qw[
    Animalia
    Bacteria
    Fungi
    Plantae
    Protista
    Unknown
];

# Process command line arguments
my $db_file; # where to access database file
my $log_level = 'INFO'; # verbosity level for logger
GetOptions(
    'db=s'  => \$db_file,
    'log=s' => \$log_level,
);

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = $log_level, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 0
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

# Instantiate logger
my $log = Log::Log4perl->get_logger('load_taxonomy');

# Connect to the database. Because there is a column `order` in the BCDM, we need to
# escape this. In SQLite that's with double quotes.
$log->info("Going to connect to database $db_file");
my $schema = BCDM::ORM->connect("dbi:SQLite:$db_file", "", "", { quote_char => '"' });

# Start iterating at the roots
for my $kingdom ( @kingdoms ) {
    $log->info("Processing kingdom $kingdom");
    #recurse(undef, $kingdom, $kingdom);
}

# Iterate over all BOLD records to link to the taxa table
$log->info("Going to link BOLD records to normalized taxa");
my $rs = $schema->resultset('Bold')->search({});
while (my $record = $rs->next) {
    $log->info('Processing record '.$record->recordid) unless $record->recordid % 10_000;

    # Lookup to what level this was identified, assume lowest level if NULL
    my $level = $record->identification_rank || 'subspecies';
    $level = 'subfamily' if $level eq 'tribe';
    my $name = $record->$level; # In nice records this ought to work

    # If we don't have a $name, we'll have to brute force up the taxonomic ranks to find
    # the lowest level with a name.
    if ( $name eq 'None' ) {
        $log->debug("Name at the identified rank $level is $name for record ".$record->recordid);
        ASCENDING_LEVELS: for ( my $i = $#levels; $i >= 0; $i-- ) {
            my $l = $levels[$i];
            if ( $record->$l ne 'None' ) {
                $level = $l;
                last ASCENDING_LEVELS;
            }
        }
        $log->debug("Using named level $level instead");
    }

    # Get the taxa that have this level and name
    my $restrict = { level => $level, name => $record->$level, kingdom => $record->kingdom };
    $log->debug(Dumper($restrict));
    my $taxa = $schema->resultset('Taxa')->search($restrict);

    # TODO Check why we are getting multiple hits
    if ( $taxa->count > 1 ) {
        $log->warn('Multiple hits for '.Dumper($restrict).' record ID: '.$record->recordid);
    }
    else {
        $record->taxonid($taxa->first->taxonid);
    }
}

# Recursive function that traverses the taxonomic levels and distinct taxa
# at those levels, gradually populating the tree structure in a depth-first
# traversal.
sub recurse {
    my ( $parent, $kingdom, @path ) = @_;
    my %keys = map { $levels[$_] => $path[$_] } 0 .. $#path;
    $log->debug(Dumper(\%keys));

    # Instantiate current level => name
    my $level = $levels[$#path];
    my $name  = $path[-1];
    my $taxon = $schema->resultset('Taxa')->create({
        name           => $name,
        level          => $level,
        kingdom        => $kingdom,
        parent_taxonid => $parent ? $parent->taxonid : undef,
    });
    $taxon->insert;
    $log->debug("Instantiated taxon object $taxon");

    # Fetch distinct children, if there is a taxonomic level below this
    my $child_level = $levels[$#path + 1];
    if ( defined $child_level ) {
        my $restrict = { columns => [ $child_level ], distinct => 1 };
        my @children = $schema->resultset('Bold')->search(\%keys, $restrict)->get_column($child_level)->all();

        # Recurse further if there are children. Note that this also recurses
        # through 'None' levels. Let's assume that this is fine...
        for my $child (@children) {
            $log->debug("Going to process child taxon $child");
            recurse($taxon, $kingdom, @path, $child);
        }
    }

    # Report progress
    $log->info("Processed $level $name (" . $taxon->taxonid . ")") unless $taxon->taxonid % 10_000;
}