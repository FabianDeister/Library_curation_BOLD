use strict;
use warnings;
use DBI;
use Text::CSV;
use Getopt::Long;
use Log::Log4perl qw(:easy);

# Process command line arguments
my $bold_tsv;   # location of BOLD TSV dump
my $db_file;    # where to create database file
my $schema_sql; # location of table creation statement(s)
my $overwrite;  # overwrite existing DB
my $log_level = 'INFO'; # verbosity level for logger
GetOptions(
    'tsv=s' => \$bold_tsv,
    'db=s'  => \$db_file,
    'sql=s' => \$schema_sql,
    'log=s' => \$log_level,
    'force' => \$overwrite
);

# Initialize Log::Log4perl
Log::Log4perl->init(\<<"END");
  log4perl.rootLogger = $log_level, Screen
  log4perl.appender.Screen = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr = 0
  log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
END

# Instantiate logger
my $log = Log::Log4perl->get_logger('load_database');

# Create the SQLite database - delete old
unlink($db_file) if $overwrite;
die 'Database exists and --force not specified' if -e $db_file;
$log->info("Going to create database $db_file with schema $schema_sql");
system("sqlite3 $db_file < $schema_sql");

# Connect to it with the DataBase Interface (DBI) module system
$log->info("Going to connect to created database $db_file using the DBI");
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");

# Connect to the BOLD TSV as binary, with UTF-8
$log->info("Going to read BOLD TSV dump $bold_tsv");
my $tsv = Text::CSV->new({ sep_char => "\t", binary => 1, auto_diag => 1, allow_whitespace => 1, quote_char => undef });
open my $fh, "<:encoding(utf8)", $bold_tsv or die "Could not open file '$bold_tsv': $!";

# Iterate over the rows as hash refs
my $PK = 1;
$tsv->column_names($tsv->getline($fh));
while (my $row = $tsv->getline_hr($fh)) {

    # Make comma-separated column names and values, prefixed with primary key
    my $columns = 'recordid,' . join ", ", map { $dbh->quote($_) } keys %$row;
    my $values  = $PK++ . ',' . join ", ", map { $dbh->quote($_) } values %$row;

    # Create insert statement and execute
    my $table = 'bold';
    my $sql = "INSERT INTO $table ($columns) VALUES ($values)";
    $dbh->do($sql) or die $dbh->errstr;

    # Log progress
    $log->info("Processed record $PK") unless $PK % 10_000;
}
