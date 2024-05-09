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
  is_foreign_key: 1
  is_nullable: 1

=head2 level

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 kingdom

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "taxonid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "parent_taxonid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "level",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "kingdom",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</taxonid>

=back

=cut

__PACKAGE__->set_primary_key("taxonid");

=head1 RELATIONS

=head2 bold_targets

Type: has_many

Related object: L<BCDM::ORM::Result::BoldTarget>

=cut

__PACKAGE__->has_many(
  "bold_targets",
  "BCDM::ORM::Result::BoldTarget",
  { "foreign.taxonid" => "self.taxonid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bolds

Type: has_many

Related object: L<BCDM::ORM::Result::Bold>

=cut

__PACKAGE__->has_many(
  "bolds",
  "BCDM::ORM::Result::Bold",
  { "foreign.taxonid" => "self.taxonid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent_taxonid

Type: belongs_to

Related object: L<BCDM::ORM::Result::Taxa>

=cut

__PACKAGE__->belongs_to(
  "parent_taxonid",
  "BCDM::ORM::Result::Taxa",
  { taxonid => "parent_taxonid" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 taxas

Type: has_many

Related object: L<BCDM::ORM::Result::Taxa>

=cut

__PACKAGE__->has_many(
  "taxas",
  "BCDM::ORM::Result::Taxa",
  { "foreign.parent_taxonid" => "self.taxonid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2024-01-26 17:05:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lO6Wzzul6STQQphslbumzQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub lineage {
    my $self = shift;
    my @lineage = ($self);
    my $parent = $self->parent_taxonid;
    while ( $parent ) {
        push @lineage, $parent;
        $parent = $parent->parent_taxonid;
    }
    return @lineage;
}

1;
