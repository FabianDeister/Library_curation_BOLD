use utf8;
package BCDM::ORM::Result::Taxa;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BCDM::ORM::Result::Taxa

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<taxa>

=cut

__PACKAGE__->table("taxa");

=head1 ACCESSORS

=head2 taxonid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 parent_taxonid

  data_type: 'integer'
  is_nullable: 1

=head2 level

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "taxonid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "parent_taxonid",
  { data_type => "integer", is_nullable => 1 },
  "level",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</taxonid>

=back

=cut

__PACKAGE__->set_primary_key("taxonid");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-26 14:54:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:n3vrrAMaOCkVJwo479N3FA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
