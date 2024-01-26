BOLD_TSV=../../resources/BOLD_Public.19-Jan-2024.tsv
DB_FILE=../../results/bold.db
SCHEMA=./schema.sql
INDEXES=./indexes.sql
LIBS=../../lib

# Creates the empty database, reads BCDM TSV
# and dumps it into the database
perl load_bcdm.pl \
  --tsv=$BOLD_TSV \
  --db=$DB_FILE \
  --sql=$SCHEMA \
  --log=INFO \
  --force

# Applies additional indexes to the database
sqlite3 $DB_FILE < $INDEXES

# Exports the database schema as Perl modules
dbicdump -o dump_directory=$LIBS BCDM::ORM "dbi:SQLite:dbname=$DB_FILE"

# Here comes a script that uses the ORM to populate the normalized taxonomy tree

# Here comes a script that imports the target list, its synonyms, and mapping to taxonomy tree


