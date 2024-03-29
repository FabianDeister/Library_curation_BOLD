use utf8;
package BCDM::ORM::Result::Target;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BCDM::ORM::Result::Target

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<targets>

=cut

__PACKAGE__->table("targets");

=head1 ACCESSORS

=head2 targetid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 targetlist

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "targetid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "targetlist",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</targetid>

=back

=cut

__PACKAGE__->set_primary_key("targetid");

=head1 RELATIONS

=head2 bold_targets

Type: has_many

Related object: L<BCDM::ORM::Result::BoldTarget>

=cut

__PACKAGE__->has_many(
  "bold_targets",
  "BCDM::ORM::Result::BoldTarget",
  { "foreign.targetid" => "self.targetid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 synonyms

Type: has_many

Related object: L<BCDM::ORM::Result::Synonym>

=cut

__PACKAGE__->has_many(
  "synonyms",
  "BCDM::ORM::Result::Synonym",
  { "foreign.targetid" => "self.targetid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-26 17:01:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+t1iZ1khUY5OVjAj/2GUzQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
