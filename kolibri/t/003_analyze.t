#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;
#use Test::More tests => 8; ;

use lib '/var/www/kolibri/lib';
use Kolibri::Filename::Analyzer;

use Data::Dumper;
my $DEBUG = 0;

my @test_customers = (
  [ 1, '49 ідей', '49i, 49?' ],
  [ 2, 'Центр Друку', 'centrdruk, centr_druk, centrdryky' ],
  [ 3, 'Поліграфцентр', 'poligrafcentr, poligrafcenter' ],
);

my @test_materials = (
  [ 1, 'Orakal', 'orakal, oracal, orocal' ],
  [ 2, 'Baner', 'baner, banner' ],
  [ 3, 'Papir', 'papir, paper' ],
);

my @test_extra = (
  [ 1, 'Люверси', 'luvers' ]

);

my $analyzer = Kolibri::Filename::Analyzer->new({
  debug          => $DEBUG,
  customers      => [ map { { id => $_->[0], name => $_->[1], aliases => $_->[2] } }  @test_customers ],
  materials      => [ map { { id => $_->[0], name => $_->[1], aliases => $_->[2] } }  @test_materials ],
  extra_elements => [ map { { id => $_->[0], name => $_->[1], aliases => $_->[2] } }  @test_extra ],
  #  debug => 1
});

my @test_rows = (
  {
    input    => 'druk_oracal_200x400_2copy_luvers_49i.tif',
    expected => {
      material       => 1,
      customer       => 1,
      copies         => 2,
      extra_elements => [ 1 ]
    }
  },
  {
    input    => 'Oracal  1 copy 150x100_Poligrafcenter(3).tif',
    expected => {
      material       => 1,
      customer       => 3,
      copies         => 1,
      extra_elements => [ ]
    }
  },
  {
    input    => 'ArtV_druk_na_baner_z_pidvorotom luversa_2960x2260_1copy_49i.tif',
    expected => {
      material       => 2,
      customer       => 1,
      copies         => 1,
      extra_elements => [ 1 ]
    }
  }
);

foreach my $tested ( @test_rows ) {
  
  my $analyzed = $analyzer->analyze($tested->{input});
  
  #  print Dumper $analyzed;
  
  # Test material
  ok(defined $analyzed->{materials} && $analyzed->{materials} == $tested->{expected}->{material},
    'Found material for ' . $tested->{input});
  
  # Test customer
  ok(defined $analyzed->{customers} && $analyzed->{customers} == $tested->{expected}->{customer},
    "Found customer $tested->{expected}->{customer} for " . $tested->{input});
  
  # Test copies
  ok(defined $analyzed->{customers} && $analyzed->{customers} == $tested->{expected}->{customer},
    "Found $tested->{expected}->{copies} copies for " . $tested->{input});
  
  # Test extra
  ok(defined $analyzed->{extra_elements}
      && scalar(@{$analyzed->{extra_elements}}) == scalar(@{$tested->{expected}->{extra_elements}}
      && $analyzed->{extra_elements}->[0] == $tested->{expected}->{extra_elements}->[0]
    ),
    "Found right count of extra elements in $tested->{input}"
  );
  
  
  
}

done_testing();

