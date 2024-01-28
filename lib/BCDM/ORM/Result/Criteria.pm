use utf8;
package BCDM::ORM::Result::Criteria;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BCDM::ORM::Result::Criteria

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<criteria>

=cut

__PACKAGE__->table("criteria");

=head1 ACCESSORS

=head2 criterionid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "criterionid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</criterionid>

=back

=cut

__PACKAGE__->set_primary_key("criterionid");

=head1 RELATIONS

=head2 bold_criterias

Type: has_many

Related object: L<BCDM::ORM::Result::BoldCriteria>

=cut

__PACKAGE__->has_many(
  "bold_criterias",
  "BCDM::ORM::Result::BoldCriteria",
  { "foreign.criterionid" => "self.criterionid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-28 16:48:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z5YUSJBTYN1BPtJQO6SOHQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
