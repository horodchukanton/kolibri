use utf8;
package Kolibri::Schema::Result::File;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Kolibri::Schema::Result::File

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<files>

=cut

__PACKAGE__->table("files");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 uploaded

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 1

=head2 customer

  data_type: 'smallint'
  is_nullable: 0

=head2 material

  data_type: 'smallint'
  is_nullable: 0

=head2 material_price

  data_type: 'double precision'
  default_value: 0
  is_nullable: 0

=head2 extra_elements

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 extra_price

  data_type: 'double precision'
  default_value: 0
  is_nullable: 0

=head2 size

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 area

  data_type: 'double precision'
  default_value: 0
  is_nullable: 0

=head2 copies

  data_type: 'smallint'
  is_nullable: 0

=head2 price

  data_type: 'double precision'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "uploaded",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 1,
  },
  "customer",
  { data_type => "smallint", is_nullable => 0 },
  "material",
  { data_type => "smallint", is_nullable => 0 },
  "material_price",
  { data_type => "double precision", default_value => 0, is_nullable => 0 },
  "extra_elements",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "extra_price",
  { data_type => "double precision", default_value => 0, is_nullable => 0 },
  "size",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "area",
  { data_type => "double precision", default_value => 0, is_nullable => 0 },
  "copies",
  { data_type => "smallint", is_nullable => 0 },
  "price",
  { data_type => "double precision", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-07-04 06:09:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:owtO9h/LBnygtEb86GVO4w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
