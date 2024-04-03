package BCDM::Criteria::ID_METHOD;
use strict;
use warnings;
use base 'BCDM::Criteria';

# this so that we know the criterionid for
# updates in the intersection table
sub _criterion { $BCDM::Criteria::ID_METHOD }

my @pos = qw(
    descr
    det
    diss
    exam
    expert
    genit
    identifier
    key
    label
    literature
    micros
    mor
    taxonomic
    type
    vou
    guide
    flora
    specimen
    traditional
    visual
    wing
    logical
    knowledge
    photo
    verified
    key
);

my @neg = qw(
    barco
    BOLD
    CO1
    COI
    COX
    DNA
    mole
    phylo
    sequ
    tree
    bin
    silva
    ncbi
    engine
    blast
    genbank
    genetic
    its
);

my $log = __PACKAGE__->_get_logger(__PACKAGE__, 'DEBUG');

# this tests the criterion and returns
# boolean 0/1 depending on fail/pass. In
# addition, optional notes may be returned.
# Here, the criterion to assess is:
# 'Specimen was identified by morphology'
# This will involve substring matching against
# identification_method. It looks like there
# are many that start with '^BIN' or with
# '^BOLD'. Those are certainly reverse
# taxonomy.
sub _assess {
    my $package = shift;
    my $record = shift;
    my $method = $record->identification_method;
    my $id = $record->recordid;


    # Check negative matches
    # my @mn;
    # for my $pattern ( @neg ) {
    #      if ( $method =~ /$pattern/i ) {
    #         push @mn, $pattern;
    #         $log->info("Negative match for $id: $pattern")
    #     }
    # }

    # Check positive matches
    my $retval = 0;
    for my $pattern ( @pos ) {
         if ( $method =~ /$pattern/i ) {
            $retval = 1;
            $log->info("Positive match for $id: $pattern")
        }
    }

    # Return result
    return $retval, "Based on positive match against any of '@pos'";
}

1;
