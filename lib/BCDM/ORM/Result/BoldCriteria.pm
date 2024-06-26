use utf8;
package BCDM::ORM::Result::BoldCriteria;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BCDM::ORM::Result::BoldCriteria

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<bold_criteria>

=cut

__PACKAGE__->table("bold_criteria");

=head1 ACCESSORS

=head2 bold_criteria_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 recordid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 criterionid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 status

  data_type: 'integer'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "bold_criteria_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "recordid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "criterionid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bold_criteria_id>

=back

=cut

__PACKAGE__->set_primary_key("bold_criteria_id");

=head1 RELATIONS

=head2 criterionid

Type: belongs_to

Related object: L<BCDM::ORM::Result::Criteria>

=cut

__PACKAGE__->belongs_to(
  "criterionid",
  "BCDM::ORM::Result::Criteria",
  { criterionid => "criterionid" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 recordid

Type: belongs_to

Related object: L<BCDM::ORM::Result::Bold>

=cut

__PACKAGE__->belongs_to(
  "recordid",
  "BCDM::ORM::Result::Bold",
  { recordid => "recordid" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-28 17:41:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z7ZlYSWoKhLvzRF1Sv91eg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
