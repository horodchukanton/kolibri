use utf8;
package Kolibri::Schema::Result::Customer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Kolibri::Schema::Result::Customer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<customers>

=cut

__PACKAGE__->table("customers");

=head1 ACCESSORS

=head2 id

  data_type: 'smallint'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 agent

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 aliases

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "smallint", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "agent",
  { data_type => "varchar", is_nullable => 1, size => 255 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ULwcRj3W6ALnB/PloL6XiQ



1;
