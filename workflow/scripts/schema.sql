CREATE TABLE "bold"(
    "recordid" INTEGER PRIMARY KEY,
    "processid" TEXT, -- index
    "sampleid" TEXT, -- index
    "specimenid" TEXT, -- index
    "museumid" TEXT,
    "fieldid" TEXT,
    "inst" TEXT,
    "bin_uri" TEXT, -- index
    "identification" TEXT,
    "funding_src" TEXT,
    "kingdom" TEXT, -- index
    "phylum" TEXT, -- index
    "class" TEXT, -- index
    "order" TEXT, -- index
    "family" TEXT, -- index
    "subfamily" TEXT, -- index
    "genus" TEXT, -- index
    "species" TEXT, -- index
    "subspecies" TEXT, -- index
    "identified_by" TEXT,
    "voucher_type" TEXT,
    "collectors" TEXT,
    "collection_date" TEXT,
    "collection_date_accuracy" TEXT,
    "life_stage" TEXT,
    "sex" TEXT,
    "reproduction" TEXT,
    "extrainfo" TEXT,
    "notes" TEXT,
    "coord" TEXT,
    "coord_source" TEXT,
    "coord_accuracy" TEXT,
    "elev" TEXT,
    "depth" TEXT,
    "elev_accuracy" TEXT,
    "depth_accuracy" TEXT,
    "country" TEXT,
    "province" TEXT,
    "country_iso" TEXT,
    "region" TEXT,
    "sector" TEXT,
    "site" TEXT,
    "collection_time" TEXT,
    "habitat" TEXT,
    "collection_note" TEXT,
    "associated_taxa" TEXT,
    "associated_specimen" TEXT,
    "species_reference" TEXT,
    "identification_method" TEXT,
    "recordset_code_arr" TEXT,
    "gb_acs" TEXT, -- index
    "marker_code" TEXT, -- index
    "nucraw" TEXT,
    "sequence_run_site" TEXT,
    "processid_minted_date" TEXT,
    "sequence_upload_date" TEXT,
    "identification_rank" TEXT
)