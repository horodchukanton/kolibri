package Kolibri::DB;
use strict;
use warnings;
use Kolibri::Schema;

my $db;
my $db_name = $ENV{'KOLIBRI_DB'} || 'kolibri';
my $db_user = $ENV{'KOLIBRI_DB_USER'} || 'kolibri';
my $db_pass = $ENV{'KOLIBRI_DB_PASS'} || 'kolibri_development';

our @EXPORT_OK = qw/
  db
  schema
  /;
our @EXPORT = @EXPORT_OK;

use Exporter;
use parent 'Exporter';


# db singleton
sub db {
  $db ||= Kolibri::Schema->connect('dbi:mysql:' . $db_name, $db_user, $db_pass, {
      quote_names       => 1,
      mysql_enable_utf8 => 1,
    });
}

sub schema {
  return db()->resultset(shift);
}

1;