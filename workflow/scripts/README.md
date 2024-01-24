# Scripts
This directory contains all scripts that were used to automate library curation

# read_snapshot_data.pl
## Overview

This Perl script is designed to extract and process data from BOLD (Barcode of Life Data Systems) snapshot datasets. BOLD provides a comprehensive collection of DNA barcode sequences linked with specimen and species information. The script reads a BOLD snapshot file in tab-separated values (tsv) format, filters relevant information, and outputs a summary in a structured CSV format.
### Usage
perl read_snapshot_data.pl -f <BOLD_snapshot_file>

    -f <BOLD_snapshot_file>: Specify the BOLD snapshot file to be processed.

## Script Structure

The script comprises two main sections:
1. Species and Synonyms Extraction

    Reads a file named all_specs_and_syn.csv.
    Populates three hash tables (%true, %europ, and %done) to handle species names, their synonyms, and processing status.

2. BOLD Snapshot Data Processing

    Reads the specified BOLD snapshot file.
    Filters and processes relevant information.
    Utilizes a subroutine (read_bold_public) to extract specific data fields.
    Outputs the processed data to a file named filtered_informations.csv.

## Output Format

The output CSV file (filtered_informations.csv) contains the following columns:

    sampleid: Sample ID from the BOLD dataset.
    species: Original species name from the BOLD dataset.
    real_species: Valid species name (resolved from synonyms).
    ident_rank: Identification rank (e.g., species, family, genus).
    voucher_type: Type of sample (Holotype, Paratype, DNA, frozen, etc.).
    seqlength: Length of the DNA sequence.
    ambiguities: Number of ambiguous sites in the sequence.
    museum_id: Museum ID.
    institut: Institution where the sample is stored.
    identifier: Person/institution that identified the sample.
    country: Country where the sample was collected.
    BIN: BOLD Identification Number.
    (Additional columns as needed)

## Notes

    The script utilizes the Getopt::Long module for command-line parameter handling.
    The input BOLD snapshot file should be in tab-separated values (tsv) format.
    The script creates and appends to the filtered_informations.csv file. If it exists, it is deleted and recreated.

## Example

    perl read_snapshot_data.pl -f bold_snapshot_data.tsv
