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
    lit
    micros
    mor
    taxonomy
    type
    vou
);

my @neg = qw(
    barco
    BOLD
    CO1
    COI
    COX
    DNA
    mole
    phyl
    sequ
    tree
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

    # Check positive matches
    my @mp;
    for my $pattern ( @pos ) {
         if ( $method =~ /$pattern/ ) {
            push @mp, $pattern;
            $log->info("Positive match for $id: $pattern")
        }
    }

    # Check negative matches
    my @mn;
    for my $pattern ( @neg ) {
         if ( $method =~ /$pattern/ ) {
            push @mn, $pattern;
            $log->info("Negative match for $id: $pattern")
        }
    }

    # Return result
    return @mp > @mn ? 1 : 0, "Based on pos > neg matches (@mp > @mn)";
}

1;
