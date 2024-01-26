use utf8;
package BCDM::ORM::Result::Bold;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BCDM::ORM::Result::Bold

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<bold>

=cut

__PACKAGE__->table("bold");

=head1 ACCESSORS

=head2 recordid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 processid

  data_type: 'text'
  is_nullable: 1

=head2 sampleid

  data_type: 'text'
  is_nullable: 1

=head2 specimenid

  data_type: 'text'
  is_nullable: 1

=head2 museumid

  data_type: 'text'
  is_nullable: 1

=head2 fieldid

  data_type: 'text'
  is_nullable: 1

=head2 inst

  data_type: 'text'
  is_nullable: 1

=head2 bin_uri

  data_type: 'text'
  is_nullable: 1

=head2 identification

  data_type: 'text'
  is_nullable: 1

=head2 funding_src

  data_type: 'text'
  is_nullable: 1

=head2 kingdom

  data_type: 'text'
  is_nullable: 1

=head2 phylum

  data_type: 'text'
  is_nullable: 1

=head2 class

  data_type: 'text'
  is_nullable: 1

=head2 order

  data_type: 'text'
  is_nullable: 1

=head2 family

  data_type: 'text'
  is_nullable: 1

=head2 subfamily

  data_type: 'text'
  is_nullable: 1

=head2 genus

  data_type: 'text'
  is_nullable: 1

=head2 species

  data_type: 'text'
  is_nullable: 1

=head2 subspecies

  data_type: 'text'
  is_nullable: 1

=head2 identified_by

  data_type: 'text'
  is_nullable: 1

=head2 voucher_type

  data_type: 'text'
  is_nullable: 1

=head2 collectors

  data_type: 'text'
  is_nullable: 1

=head2 collection_date

  data_type: 'text'
  is_nullable: 1

=head2 collection_date_accuracy

  data_type: 'text'
  is_nullable: 1

=head2 life_stage

  data_type: 'text'
  is_nullable: 1

=head2 sex

  data_type: 'text'
  is_nullable: 1

=head2 reproduction

  data_type: 'text'
  is_nullable: 1

=head2 extrainfo

  data_type: 'text'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 coord

  data_type: 'text'
  is_nullable: 1

=head2 coord_source

  data_type: 'text'
  is_nullable: 1

=head2 coord_accuracy

  data_type: 'text'
  is_nullable: 1

=head2 elev

  data_type: 'text'
  is_nullable: 1

=head2 depth

  data_type: 'text'
  is_nullable: 1

=head2 elev_accuracy

  data_type: 'text'
  is_nullable: 1

=head2 depth_accuracy

  data_type: 'text'
  is_nullable: 1

=head2 country

  data_type: 'text'
  is_nullable: 1

=head2 province

  data_type: 'text'
  is_nullable: 1

=head2 country_iso

  data_type: 'text'
  is_nullable: 1

=head2 region

  data_type: 'text'
  is_nullable: 1

=head2 sector

  data_type: 'text'
  is_nullable: 1

=head2 site

  data_type: 'text'
  is_nullable: 1

=head2 collection_time

  data_type: 'text'
  is_nullable: 1

=head2 habitat

  data_type: 'text'
  is_nullable: 1

=head2 collection_note

  data_type: 'text'
  is_nullable: 1

=head2 associated_taxa

  data_type: 'text'
  is_nullable: 1

=head2 associated_specimen

  data_type: 'text'
  is_nullable: 1

=head2 species_reference

  data_type: 'text'
  is_nullable: 1

=head2 identification_method

  data_type: 'text'
  is_nullable: 1

=head2 recordset_code_arr

  data_type: 'text'
  is_nullable: 1

=head2 gb_acs

  data_type: 'text'
  is_nullable: 1

=head2 marker_code

  data_type: 'text'
  is_nullable: 1

=head2 nucraw

  data_type: 'text'
  is_nullable: 1

=head2 sequence_run_site

  data_type: 'text'
  is_nullable: 1

=head2 processid_minted_date

  data_type: 'text'
  is_nullable: 1

=head2 sequence_upload_date

  data_type: 'text'
  is_nullable: 1

=head2 identification_rank

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "recordid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "processid",
  { data_type => "text", is_nullable => 1 },
  "sampleid",
  { data_type => "text", is_nullable => 1 },
  "specimenid",
  { data_type => "text", is_nullable => 1 },
  "museumid",
  { data_type => "text", is_nullable => 1 },
  "fieldid",
  { data_type => "text", is_nullable => 1 },
  "inst",
  { data_type => "text", is_nullable => 1 },
  "bin_uri",
  { data_type => "text", is_nullable => 1 },
  "identification",
  { data_type => "text", is_nullable => 1 },
  "funding_src",
  { data_type => "text", is_nullable => 1 },
  "kingdom",
  { data_type => "text", is_nullable => 1 },
  "phylum",
  { data_type => "text", is_nullable => 1 },
  "class",
  { data_type => "text", is_nullable => 1 },
  "order",
  { data_type => "text", is_nullable => 1 },
  "family",
  { data_type => "text", is_nullable => 1 },
  "subfamily",
  { data_type => "text", is_nullable => 1 },
  "genus",
  { data_type => "text", is_nullable => 1 },
  "species",
  { data_type => "text", is_nullable => 1 },
  "subspecies",
  { data_type => "text", is_nullable => 1 },
  "identified_by",
  { data_type => "text", is_nullable => 1 },
  "voucher_type",
  { data_type => "text", is_nullable => 1 },
  "collectors",
  { data_type => "text", is_nullable => 1 },
  "collection_date",
  { data_type => "text", is_nullable => 1 },
  "collection_date_accuracy",
  { data_type => "text", is_nullable => 1 },
  "life_stage",
  { data_type => "text", is_nullable => 1 },
  "sex",
  { data_type => "text", is_nullable => 1 },
  "reproduction",
  { data_type => "text", is_nullable => 1 },
  "extrainfo",
  { data_type => "text", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "coord",
  { data_type => "text", is_nullable => 1 },
  "coord_source",
  { data_type => "text", is_nullable => 1 },
  "coord_accuracy",
  { data_type => "text", is_nullable => 1 },
  "elev",
  { data_type => "text", is_nullable => 1 },
  "depth",
  { data_type => "text", is_nullable => 1 },
  "elev_accuracy",
  { data_type => "text", is_nullable => 1 },
  "depth_accuracy",
  { data_type => "text", is_nullable => 1 },
  "country",
  { data_type => "text", is_nullable => 1 },
  "province",
  { data_type => "text", is_nullable => 1 },
  "country_iso",
  { data_type => "text", is_nullable => 1 },
  "region",
  { data_type => "text", is_nullable => 1 },
  "sector",
  { data_type => "text", is_nullable => 1 },
  "site",
  { data_type => "text", is_nullable => 1 },
  "collection_time",
  { data_type => "text", is_nullable => 1 },
  "habitat",
  { data_type => "text", is_nullable => 1 },
  "collection_note",
  { data_type => "text", is_nullable => 1 },
  "associated_taxa",
  { data_type => "text", is_nullable => 1 },
  "associated_specimen",
  { data_type => "text", is_nullable => 1 },
  "species_reference",
  { data_type => "text", is_nullable => 1 },
  "identification_method",
  { data_type => "text", is_nullable => 1 },
  "recordset_code_arr",
  { data_type => "text", is_nullable => 1 },
  "gb_acs",
  { data_type => "text", is_nullable => 1 },
  "marker_code",
  { data_type => "text", is_nullable => 1 },
  "nucraw",
  { data_type => "text", is_nullable => 1 },
  "sequence_run_site",
  { data_type => "text", is_nullable => 1 },
  "processid_minted_date",
  { data_type => "text", is_nullable => 1 },
  "sequence_upload_date",
  { data_type => "text", is_nullable => 1 },
  "identification_rank",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</recordid>

=back

=cut

__PACKAGE__->set_primary_key("recordid");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-26 10:15:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BkaE28G5oT5Ys3Odx69BBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
