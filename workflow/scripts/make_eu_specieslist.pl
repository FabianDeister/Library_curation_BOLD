use strict;
use warnings;
use DBI;
use Text::CSV;
use Getopt::Long;

# Lookup table for European country ISO codes
my @ISO = qw[
    AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE
    AL AD AM BY BA FO GE GI IS IM XK LI MK MD MC ME NO RU SM RS CH TR UA GB VA
];
my %ISO = map { $_ => 1 } @ISO;

# Process command line arguments
my $dbfile;   # where to access SQLite database
my $families; # TSV file with family names
GetOptions(
    'dbfile=s'   => \$dbfile,
    'families=s' => \$families
);

# Initialize Text::CSV reader
my $tsv = Text::CSV->new({
    sep_char         => "\t",
    binary           => 1,
    auto_diag        => 1,
    allow_whitespace => 1,
    quote_char       => undef
});

# Connect to the SQLite database
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");

# Connect to the families TSV as binary, with UTF-8, for reading
open my $fh, "<:encoding(utf8)", $families or die "Could not open file '$families': $!";
my @keys = @{$tsv->getline($fh)};
$tsv->column_names(\@keys);

# Print header and iterate over lines
print join("\t", @keys, 'species'), "\n";
while ( my $row = $tsv->getline_hr($fh) ) {

    # Expand this family
    my $family = $row->{'family'};

    # Prepare the SQL statement to fetch all species in this family from the bold table, in alphabetical order
    my $sql = "SELECT DISTINCT species FROM bold WHERE family = ? ORDER BY species";
    my $sth = $dbh->prepare($sql) or die $dbh->errstr;
    $sth->execute($family) or die $dbh->errstr;

    # Iterate over the species as hash refs
    SPECIES: while ( my $species = $sth->fetchrow_hashref() ) {

        # Fetch all country ISO codes for this species
        my $name = $species->{'species'};
        $sql = "SELECT DISTINCT country_iso FROM bold WHERE species = ?";
        $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute($name) or die $dbh->errstr;

        # Iterate over the country ISO codes
        while ( my $country = $sth->fetchrow_hashref() ) {
            my $country_iso = $country->{'country_iso'};
            if ( $ISO{$country_iso} ) {

                # Print the species name
                print join("\t", map( { $row->{$_} } @keys ), $name), "\n";
                next SPECIES;
            }
        }
    }
}

1;