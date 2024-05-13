#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Text::CSV;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

# Command line options
my ($filter_file, $database_file);
GetOptions(
    'filter=s'   => \$filter_file,
    'database=s' => \$database_file,
) or die "Usage: $0 --filter <filter_file> --database <database_file>\n";

# Check required arguments
die "Usage: $0 --filter <filter_file> --database <database_file>\n" unless $filter_file && $database_file;

# Read filter file
open my $fh_filter, '<', $filter_file or die "Could not open '$filter_file': $!\n";
my $csv = Text::CSV->new({ sep_char => "\t", binary => 1 });

# Parse filter file header
my $headers = $csv->getline($fh_filter);
$csv->column_names(@$headers);

# Store filter predicates
my @filter_predicates;
while (my $row = $csv->getline_hr($fh_filter)) {
    push @filter_predicates, $row;
}
close $fh_filter;

# Open database file (handle gzipped file)
my $fh_database;
if ($database_file =~ /\.gz$/) {
    $fh_database = IO::Uncompress::Gunzip->new($database_file) or die "gunzip failed: $GunzipError\n";
} else {
    open $fh_database, '<', $database_file or die "Could not open '$database_file': $!\n";
}

# Read database file
my $csv_db = Text::CSV->new({ sep_char => "\t", binary => 1 });
my $db_headers = $csv_db->getline($fh_database);
$csv_db->column_names(@$db_headers);

# Print database header
print join("\t", @$db_headers), "\n";

# Function to check if a database row matches any filter predicate
sub matches_filter {
    my ($db_row) = @_;
    foreach my $filter (@filter_predicates) {
        my $match = 1;
        foreach my $key (keys %$filter) {
            if (!defined $db_row->{$key} || $db_row->{$key} ne $filter->{$key}) {
                $match = 0;
                last;
            }
        }
        return 1 if $match;
    }
    return 0;
}

# Filter and print database rows
while (my $db_row = $csv_db->getline_hr($fh_database)) {
    if (matches_filter($db_row)) {
        print join("\t", @{$db_row}{@$db_headers}), "\n";
    }
}

close $fh_database;
