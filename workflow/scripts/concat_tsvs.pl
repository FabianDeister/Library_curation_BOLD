use strict;
use warnings;

# all input files are simply provided on the command line, so the
# usage is `perl concat_tsvs.pl INFILE1.tsv INFILE2.tsv > CONCATENATED.tsv`
my @infiles = @ARGV;
my $PK = 1;

# iterate over input files
for my $infile ( @infiles ) {
	open my $fh, '<', $infile or die $!;
	while(<$fh>) {
		
		# we assume the input is sane, so:
		# - we don't chomp, we just reuse the line break
		# - we don't split the line, we just prefix it with $PK\t
		print $PK++, "\t", $_;
	}

}
