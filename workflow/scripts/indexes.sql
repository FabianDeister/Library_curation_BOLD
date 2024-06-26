-- indexes on the bold table. More might be needed.
CREATE INDEX IF NOT EXISTS "processid_idx" ON bold ("processid");
CREATE INDEX IF NOT EXISTS "sampleid_idx" ON bold ("sampleid");
CREATE INDEX IF NOT EXISTS "specimenid_idx" ON bold ("specimenid");
CREATE INDEX IF NOT EXISTS "bin_uri_idx" ON bold ("bin_uri");
CREATE INDEX IF NOT EXISTS "kingdom_idx" ON bold ("kingdom");
CREATE INDEX IF NOT EXISTS "phylum_idx" ON bold ("phylum");
CREATE INDEX IF NOT EXISTS "class_idx" ON bold ("class");
CREATE INDEX IF NOT EXISTS "order_idx" ON bold ("order");
CREATE INDEX IF NOT EXISTS "family_idx" ON bold ("family");
CREATE INDEX IF NOT EXISTS "subfamily_idx" ON bold ("subfamily");
CREATE INDEX IF NOT EXISTS "genus_idx" ON bold ("genus");
CREATE INDEX IF NOT EXISTS "species_idx" ON bold ("species");
CREATE INDEX IF NOT EXISTS "subspecies_idx" ON bold ("subspecies");
CREATE INDEX IF NOT EXISTS "insdc_acs_idx" ON bold ("insdc_acs");
CREATE INDEX IF NOT EXISTS "marker_code_idx" ON bold ("marker_code");
CREATE INDEX IF NOT EXISTS "voucher_type_idx" ON bold ("voucher_type");
CREATE INDEX IF NOT EXISTS "identified_by_idx" ON bold ("identified_by");
CREATE INDEX IF NOT EXISTS "identification_rank_idx" ON bold ("identification_rank");
CREATE INDEX IF NOT EXISTS "identification_method_idx" ON bold ("identification_method");
CREATE INDEX IF NOT EXISTS "taxonid_idx" ON bold ("taxonid");
CREATE INDEX IF NOT EXISTS "notes_idx" ON bold ("notes");
-- CREATE INDEX IF NOT EXISTS "extrainfo_idx" ON bold ("extrainfo"); -- TODO what did this change into?

-- indexes on the targets table
CREATE INDEX IF NOT EXISTS "target_name_idx" on targets ("name");
CREATE INDEX IF NOT EXISTS "targetlist_idx" on targets ("targetlist");

-- indexes on the synonyms table
CREATE INDEX IF NOT EXISTS "synonym_name_idx" on synonyms ("name");
CREATE INDEX IF NOT EXISTS "targetid_idx" on synonyms ("targetid");

-- indexes on the taxa table
CREATE INDEX IF NOT EXISTS "level_idx" on taxa ("level");
CREATE INDEX IF NOT EXISTS "taxa_name_idx" on taxa ("name");
CREATE INDEX IF NOT EXISTS "kingdom_idx" on taxa ("kingdom");
CREATE INDEX IF NOT EXISTS "full_idx" on taxa ("kingdom","level","name");
CREATE INDEX IF NOT EXISTS "total_idx" on taxa ("kingdom","level","name", "parent_taxonid");
CREATE INDEX IF NOT EXISTS "parent_taxonid_idx" on taxa ("parent_taxonid");

-- indexes on the bold_targets table
CREATE INDEX IF NOT EXISTS "taxonid_idx" ON bold_targets ("taxonid_idx");
CREATE INDEX IF NOT EXISTS "targetid_idx" on bold_targets ("targetid");

-- progressive taxon hierarchy indexes
CREATE INDEX IF NOT EXISTS "kp_idx" ON bold ("kingdom", "phylum");
CREATE INDEX IF NOT EXISTS "kpc_idx" ON bold ("kingdom", "phylum", "class");
CREATE INDEX IF NOT EXISTS "kpco_idx" ON bold ("kingdom", "phylum", "class", "order");
CREATE INDEX IF NOT EXISTS "kpcof_idx" ON bold ("kingdom", "phylum", "class", "order", "family");
CREATE INDEX IF NOT EXISTS "kpcofs_idx" ON bold ("kingdom", "phylum", "class", "order", "family", "subfamily");
CREATE INDEX IF NOT EXISTS "kpcofsg_idx" ON bold ("kingdom", "phylum", "class", "order", "family", "subfamily", "genus");
CREATE INDEX IF NOT EXISTS "kpcofsgs_idx" ON bold ("kingdom", "phylum", "class", "order", "family", "subfamily", "genus", "species");
CREATE INDEX IF NOT EXISTS "kpcofsgss_idx" ON bold ("kingdom", "phylum", "class", "order", "family", "subfamily", "genus", "species", "subspecies");

-- indexes on criteria
CREATE INDEX IF NOT EXISTS "name_idx" on criteria ("name");

-- indexes on bold_criteria intersection
CREATE INDEX IF NOT EXISTS "recordid_idx" on bold_criteria ("recordid");
CREATE INDEX IF NOT EXISTS "criterionid_idx" on bold_criteria ("criterionid");
CREATE INDEX IF NOT EXISTS "status_idx" on bold_criteria ("status");
