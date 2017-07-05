use strict;
use warnings FATAL => 'all';
use utf8;

my @template_rows = (
  {
    name      => 'id',
    id        => 'id',
    type      => 'hidden',
    lang_name => '#'
  },
  {
    name      => 'name',
    id        => 'name',
    type      => 'text',
    lang_name => 'Назва'
  },
  {
    name      => 'agent',
    id        => 'agent',
    type      => 'text',
    lang_name => 'Представник'
  },
  {
    name      => 'email',
    id        => 'email',
    type      => 'email',
    lang_name => 'EMail'
  },
  {
    name      => 'phone',
    id        => 'phone',
    type      => 'text',
    lang_name => 'Телефон'
  },
  {
    name      => 'aliases',
    id        => 'aliases',
    type      => 'text',
    lang_name => 'Ключові слова'
  }
);
my $SCHEMA = schema('Customer');
my $ROUTE = '/customers';
my $NAME = 'Customer';

# Show
get $ROUTE => route_show_list($SCHEMA, $ROUTE, $NAME, \@template_rows);

# Create
post $ROUTE => route_create($SCHEMA, $ROUTE);

# Preview single
get $ROUTE . '/change/:id' => route_preview_single($SCHEMA, $ROUTE, $NAME, \@template_rows);

# Change single
post $ROUTE . '/change' => route_change($SCHEMA, $ROUTE, $NAME, \@template_rows);

# Delete
get $ROUTE . '/delete/:id' => route_remove($SCHEMA, $ROUTE, $NAME);

1;