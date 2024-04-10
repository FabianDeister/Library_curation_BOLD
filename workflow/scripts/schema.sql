-- this table contains the verbatim contents
-- of a BOLD data dump in BCDM TSV format. The
-- table is extended with a primary key (recordid)
-- and a foreign key that links to the normalized
-- taxa table.
CREATE TABLE IF NOT EXISTS "bold"(
    "recordid" INTEGER PRIMARY KEY,
    "taxonid" INTEGER, -- index, foreign key
    "processid" TEXT,
    "sampleid" TEXT,
    "fieldid" TEXT,
    "museumid" TEXT,
    "record_id" TEXT,
    "specimenid" TEXT,
    "processid_minted_date" TEXT,
    "bin_uri" TEXT,
    "bin_created_date" TEXT,
    "collection_code" TEXT,
    "inst" TEXT,
    "taxid" TEXT,
    "kingdom" TEXT,
    "phylum" TEXT,
    "class" TEXT,
    "order" TEXT,
    "family" TEXT,
    "subfamily" TEXT,
    "tribe" TEXT,
    "genus" TEXT,
    "species" TEXT,
    "subspecies" TEXT,
    "species_reference" TEXT,
    "identification" TEXT,
    "identification_method" TEXT,
    "identification_rank" TEXT,
    "identified_by" TEXT,
    "identifier_email" TEXT,
    "taxonomy_notes" TEXT,
    "sex" TEXT,
    "reproduction" TEXT,
    "life_stage" TEXT,
    "short_notnotes" TEXT,
    "voucher_type" TEXT,
    "tissue_type" TEXT,
    "specimen_linkout" TEXT,
    "associated_specimens" TEXT,
    "associated_taxa" TEXT,
    "collectors" TEXT,
    "collection_date" TEXT,
    "collection_date_accuracy" TEXT,
    "collection_event_id" TEXT,
    "collection_time" TEXT,
    "collection_notes" TEXT,
    "geoid" TEXT,
    "country/ocean" TEXT,
    "country_iso" TEXT,
    "province" TEXT,
    "region" TEXT,
    "sector" TEXT,
    "site" TEXT,
    "site_code" TEXT,
    "coord" TEXT,
    "coord_accuracy" TEXT,
    "coord_source" TEXT,
    "elev" TEXT,
    "elev_accuracy" TEXT,
    "depth" TEXT,
    "depth_accuracy" TEXT,
    "habitat" TEXT,
    "sampling_protocol" TEXT,
    "nuc" TEXT,
    "nuc_basecount" TEXT,
    "insdc_acs" TEXT,
    "funding_src" TEXT,
    "marker_code" TEXT,
    "primers_forward" TEXT,
    "primers_reverse" TEXT,
    "sequence_run_site" TEXT,
    "sequence_upload_date" TEXT,
    "recordset_code_arr" TEXT,
    FOREIGN KEY(taxonid) REFERENCES taxa(taxonid)
);

-- the canonical names of the target list. For
-- extensibility there is a field for the name of the
-- target list (e.g. 'iBOL-Europe') so that multiple lists
-- can live here, e.g. for different projects, taxonomic
-- groups, geographic entities, etc.
CREATE TABLE IF NOT EXISTS "targets" (
    "targetid" INTEGER PRIMARY KEY, -- primary key
    "name" TEXT NOT NULL, -- index, species name
    "targetlist" TEXT NOT NULL -- index, e.g. 'iBOL-Europe'
);

-- manages the one-to-many relationship between canonical
-- names and taxonomic synonyms
CREATE TABLE IF NOT EXISTS "synonyms" (
    "synonymid" INTEGER PRIMARY KEY, -- primary key
    "name" TEXT NOT NULL, -- index, any alternate name
    "targetid" INTEGER NOT NULL, -- foreign key to targets.targetid
    FOREIGN KEY(targetid) REFERENCES targets(targetid)
);

-- this is an intersection table that manages the
-- many-to-many relationships between canonical species
-- on the target list and normalized bold taxa
CREATE TABLE IF NOT EXISTS "bold_targets" (
    "bold_target_id" INTEGER PRIMARY KEY, -- primary key
    "targetid" INTEGER, -- foreign key to targets.targetid
    "taxonid" INTEGER, -- foreign key to taxa.taxonid
    FOREIGN KEY(taxonid) REFERENCES taxa(taxonid),
    FOREIGN KEY(targetid) REFERENCES targets(targetid)
);

-- this table normalizes the taxonomy, so that every taxon
-- has a single record (i.e. according to DRY principles),
-- which is referenced by the bold table and and the
-- bold_targets table
CREATE TABLE IF NOT EXISTS "taxa" (
    "taxonid" INTEGER PRIMARY KEY, -- primary key
    "parent_taxonid" INTEGER, -- self-joining foreign key
    "level" TEXT NOT NULL, -- index, e.g. 'species'
    "name" TEXT NOT NULL, -- index, e.g. 'Homo sapiens'
    "kingdom" TEXT NOT NULL, -- index, e.g. 'Animalia', for homonyms
    FOREIGN KEY(parent_taxonid) REFERENCES taxa(taxonid)
);

-- this table lists the criteria for sequence/specimen
-- quality. The table thus corresponds with the columns
-- in table 1 of the draft document, here:
-- https://docs.google.com/document/d/18m-7UnoJTG49TbvTsq_VncKMYZbYVbau98LE_q4rQvA/edit
CREATE TABLE IF NOT EXISTS "criteria" (
    "criterionid" INTEGER PRIMARY KEY, -- primary key
    "name" TEXT NOT NULL, -- index, e.g. SPECIES_ID, TYPE_SPECIMEN, SEQ_LENGTH
    "description" TEXT NOT NULL
);

-- this table intersects between the criteria and the bold
-- records. Hence, every bold record has zero-to-many
-- criteria which have been assessed and for which the
-- record passes or fails. Passing and failing is indicated
-- by a boolean flag in the "status" column.
CREATE TABLE IF NOT EXISTS "bold_criteria" (
    "bold_criteria_id" INTEGER PRIMARY KEY, -- primary key
    "recordid" INTEGER NOT NULL, -- index, foreign key to bold table
    "criterionid" INTEGER NOT NULL, -- index, foreign key to criteria
    "status" INTEGER CHECK (status IN (0, 1)), -- boolean, whether the record qualifies for this criterion
    "notes" TEXT, -- any further notes about the status, if available
    FOREIGN KEY(recordid) REFERENCES bold(recordid),
    FOREIGN KEY(criterionid) REFERENCES criteria(criterionid)
);
