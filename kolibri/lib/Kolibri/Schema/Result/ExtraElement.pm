use utf8;
package Kolibri::Schema::Result::ExtraElement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Kolibri::Schema::Result::ExtraElement

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<extra_elements>

=cut

__PACKAGE__->table("extra_elements");

=head1 ACCESSORS

=head2 id

  data_type: 'smallint'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 price_per_one

  data_type: 'double precision'
  is_nullable: 0

=head2 aliases

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "smallint", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "price_per_one",
  { data_type => "double precision", is_nullable => 0 },
  "aliases",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-06-30 07:56:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WYF0La4WHSf/eflOZ3UDTg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
