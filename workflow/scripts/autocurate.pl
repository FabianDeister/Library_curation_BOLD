use strict;
use warnings;
use DBI;
use Text::CSV;
use Getopt::Long;

# Keep distinct sequences with the following criteria:
# - BAGS rating is A/B/C
# - Price rating is 1/2/3

# Cached BAGS rating and distinct sequences
my %BAGS;
my %SEEN;

# Process command line arguments
my $dump_tsv; # where to access annotated dump file
my $bags_tsv; # location of BAGS TSV dump
my $id_map;   # where to write process ID to taxon ID file
my $fasta;    # where to write FASTA file
GetOptions(
    'dump=s'  => \$dump_tsv,
    'bags=s'  => \$bags_tsv,
    'idmap=s' => \$id_map,
    'fasta=s' => \$fasta,
);

# Initialize Text::CSV
my $tsv = Text::CSV->new({
    sep_char         => "\t",
    binary           => 1,
    auto_diag        => 1,
    allow_whitespace => 1,
    quote_char       => undef
});

{
    # Connect to the BAGS TSV as binary, with UTF-8
    open my $fh, "<:encoding(utf8)", $bags_tsv or die "Could not open file '$bags_tsv': $!";

    # Read the BAGS TSV as hash refs, store BIN=>BAGS mapping
    my @keys = @{$tsv->getline($fh)};
    $tsv->column_names(\@keys);
    while ( my $row = $tsv->getline_hr($fh) ) {

        # Cache BAGS rating
        my $bin_url = $row->{'BIN'};
        if ( $bin_url =~ /clusteruri=(BOLD:.+)$/ ) {
            my $bin = $1;
            $BAGS{$bin} = $row->{'BAGS'};
        }
    }
}

{
    # Connect to the BCDM TSV as binary, with UTF-8
    open my $fh, "<:encoding(utf8)", $dump_tsv or die "Could not open file '$dump_tsv': $!";

    # Open ID map for writing
    open my $id_fh, ">", $id_map or die "Could not open file '$id_map': $!";

    # Open FASTA file for writing
    open my $fasta_fh, ">", $fasta or die "Could not open file '$fasta': $!";

    # Read the BCDM dump TSV as hash refs
    my @keys = @{$tsv->getline($fh)};
    $tsv->column_names(\@keys);
    RECORD: while ( my $row = $tsv->getline_hr($fh) ) {

        # Lookup BAGS rating, skip if not ABC
        my $bin = $row->{'bin_uri'};
        next RECORD if not defined $bin or $bin !~ /^BOLD:.+$/;
        my $bags = $BAGS{$bin};
        next RECORD if not defined $bags or $bags !~ /^[ABC]$/;

        # Lookup price rating, skip if not 123
        next RECORD if not defined $row->{'ranking'} or $row->{'ranking'} > 3;

        # Skip if already seen the haplotype
        my $seq = $row->{'nuc'};
        next RECORD if $SEEN{$seq}++;

        # Print the record
        my $process_id = $row->{'processid'};
        my $taxon_id   = $row->{'taxonid'};
        print $id_fh "$process_id\t$taxon_id\n";
        print $fasta_fh ">$process_id\n$seq\n";
    }
}