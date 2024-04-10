# These values need to be moved to $ROOT/config/config.yml
# so that they become available to the Snakefile, which
# passes them on to the rules that need them.
BOLD_TSV=../../resources/BOLD_Public.19-Jan-2024.tsv
DB_FILE=../../results/bold.db
SCHEMA=./schema.sql
INDEXES=./indexes.sql
LIBS=../../lib

# Creates the empty database, reads BCDM TSV
# and dumps it into the database. This would become a
# Snakefile rule, with inputs, outputs, a shell 
# command and a specification where the logs should
# end up.
perl load_bcdm.pl \
  --tsv=$BOLD_TSV \
  --db=$DB_FILE \
  --sql=$SCHEMA \
  --log=INFO \
  --force

# Applies additional indexes to the database. Same here,
# this would become a rule. Probably needs an additional
# output so that snakemake knows the rule was done. If
# the output is the input database, then snakemake can't
# figure out the status and will continue to attempt to
# do this every time.
sqlite3 $DB_FILE < $INDEXES

# Exports the database schema as Perl modules. This is
# probably not needed as a Snakefile rule each time,
# because this code now exists already. Only if the 
# database schema changes, this would have to be rerun.
dbicdump -o dump_directory=$LIBS BCDM::ORM "dbi:SQLite:dbname=$DB_FILE"

# Here comes a script that uses the ORM to populate the 
# normalized taxonomy tree. This would be a Snakefile rule.
perl -I${LIBS} load_taxonomy.pl --db=$DB_FILE --log=INFO

# Here comes a script that imports the target list, 
# its synonyms, and mapping to taxonomy tree. Again a 
# Snakefile rule.

# Here the script to assess criteria. Possibly the
# same script is invoked by multiple, separate Snakefile
# rules, e.g. one for each criterion.

# Possibly there will be a need to aggregate and
# summarise the outcomes from the different criteria
# into a single, graded value.

# And finally there would be a rule/script here 
# that outputs filtered data in BCDM.


