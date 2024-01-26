use utf8;
package BCDM::ORM::Result::BoldTarget;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BCDM::ORM::Result::BoldTarget

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<bold_targets>

=cut

__PACKAGE__->table("bold_targets");

=head1 ACCESSORS

=head2 bold_target_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 targetid

  data_type: 'integer'
  is_nullable: 0

=head2 taxonid

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "bold_target_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "targetid",
  { data_type => "integer", is_nullable => 0 },
  "taxonid",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bold_target_id>

=back

=cut

__PACKAGE__->set_primary_key("bold_target_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-26 14:54:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dyeWwvGH6z0H3PPc+nSQLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
