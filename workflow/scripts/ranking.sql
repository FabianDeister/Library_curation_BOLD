-- This script operates on the database assuming all criteria have been assessed
-- and persisted into it. It calculates the ranking of the status results for each
-- record, resulting in a `ranking` column, whose values range from 1 to 6 or null.
-- The ranks are checked sequentially such that a record matching rank 1 is not assessed
-- further and so on until rank 6 is assessed. 
-- To use this for producing an output set in BCDM TSV format, do the following:
-- $ sqlite3 bold.db
-- sqlite> .headers ON
-- sqlite> .mode tabs
-- sqlite> .output curated.tsv
-- sqlite> .read ranking.sql
-- sqlite> .quit

WITH ScoredRecords AS (
    SELECT
        b.*,
        SUM(bc.status) AS ranking
    FROM
        bold b
    LEFT JOIN
        bold_criteria bc ON b.recordid = bc.recordid
    WHERE
        b.bin_uri <> ''
    GROUP BY
        b.recordid
)

SELECT
    sr.*,
    CASE
        WHEN sr.SPECIES_ID = 1 
			AND sr.TYPE_SPECIMEN = 1 THEN 1
        WHEN sr.SPECIES_ID = 1 
			AND sr.SEQ_QUALITY = 1 
			AND sr.HAS_IMAGE = 1
			AND sr.COLLECTORS = 1 
			AND sr.COLLECTION_DATE = 1
			AND sr.COUNTRY = 1 
			AND sr.SITE = 1
			AND sr.COORD = 1 
			AND sr.IDENTIFIER = 1
			AND (sr.ID_METHOD = 1 OR sr.INSTITUTION = 1)
			AND (sr.PUBLIC_VOUCHER = 1 OR sr.MUSEUM_ID = 1) THEN 2
        WHEN sr.SPECIES_ID = 1 
			AND sr.SEQ_QUALITY = 1 
			AND sr.HAS_IMAGE = 1
			AND sr.COUNTRY = 1
			AND (sr.IDENTIFIER = 1 OR sr.ID_METHOD = 1)
			AND (sr.INSTITUTION = 1 OR sr.PUBLIC_VOUCHER = 1 OR sr.MUSEUM_ID = 1) THEN 3
        WHEN sr.SPECIES_ID = 1 
			AND sr.SEQ_QUALITY = 1 
			AND sr.HAS_IMAGE = 1
			AND sr.COUNTRY = 1 THEN 4
        WHEN sr.SPECIES_ID = 1 
			AND sr.SEQ_QUALITY = 1 
			AND sr.HAS_IMAGE = 1 THEN 5
        WHEN sr.SPECIES_ID = 1 
			AND sr.SEQ_QUALITY = 1 THEN 6
        ELSE NULL
    END AS rank
FROM (
    SELECT
        *,
        RANK() OVER (PARTITION BY bin_uri ORDER BY ranking DESC) AS rank
    FROM
        ScoredRecords
) sr
WHERE
    sr.rank = 1
    OR sr.rank = 2
    OR sr.rank = 3
    OR sr.rank = 4
    OR sr.rank = 5
    OR sr.rank = 6;
