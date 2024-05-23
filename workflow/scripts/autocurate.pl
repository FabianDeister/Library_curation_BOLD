use strict;
use warnings;
use Text::CSV;
use Getopt::Long;

# Keep distinct sequences with the following criteria:
# - BAGS rating is A/B/C
# - Price rating is 1/2/3

# Cached BAGS rating, distinct sequences, and taxonomic levels
my %BAGS;
my %SEEN;
my @LEVELS = qw[ phylum class order family genus species ];

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
    # Connect to the BAGS TSV as binary, with UTF-8, for reading
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
    # Connect to the BCDM TSV as binary, with UTF-8, for reading
    open my $fh, "<:encoding(utf8)", $dump_tsv or die "Could not open file '$dump_tsv': $!";

    # Open ID map and FASTA file for writing
    open my $id_fh,    ">", $id_map or die "Could not open file '$id_map': $!";
    open my $fasta_fh, ">", $fasta  or die "Could not open file '$fasta': $!";

    # Read the BCDM dump TSV as hash refs
    my @keys = @{$tsv->getline($fh)};
    $tsv->column_names(\@keys);
    RECORD: while ( my $row = $tsv->getline_hr($fh) ) {

        # Skip if not COI-5P
        next RECORD if not $row->{'marker_code'} or $row->{'marker_code'} ne 'COI-5P';

        # Skip empty BINs, BAGS rating > ABC, Price rating > 3
        my $bin = $row->{'bin_uri'};
        next RECORD if not $bin or $bin !~ /^BOLD:.+$/;
        next RECORD if not $BAGS{$bin} or $BAGS{$bin} !~ /^[ABC]$/;
        next RECORD if not $row->{'ranking'} or $row->{'ranking'} > 3;

        # Skip if already seen the haplotype (sans gaps)
        my $seq = $row->{'nuc'};
        $seq =~ s/-//g;
        next RECORD if $SEEN{$seq}++;

        # Print the record with lineage to FASTA and process ID-to-taxon ID map
        my $process_id = $row->{'processid'};
        my $taxon_id   = $row->{'taxonid'};
        my $defline    = join "|", 'private_BOLD', $process_id, $row->{'species'}, map { $row->{$_} } @LEVELS;
        print $id_fh "$process_id\t$taxon_id\n";
        print $fasta_fh ">$defline\n$seq\n";
    }
}