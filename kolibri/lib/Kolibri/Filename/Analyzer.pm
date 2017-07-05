package Kolibri::Filename::Analyzer;
use strict;
use warnings FATAL => 'all';

use Encode;
use Data::Dumper;
use Digest::MD5 qw(md5_base64);

#**********************************************************
=head2 new($db, $admin, $CONF)

  Arguments:
    $db    - ref to DB
    $admin - current Web session admin
    $CONF  - ref to %conf
    
  Returns:
    object
    
=cut
#**********************************************************
sub new{
  my $class = shift;
  
  my ($attr) = @_;
  
  my $self = {
    customers      => $attr->{customers},
    materials      => $attr->{materials},
    extra_elements => $attr->{extra_elements},
    rows           => [ ],
    customers_are_required => $attr->{customers_are_required},
    debug          => $attr->{debug} || 0
  };
  
  # Transform to array
  foreach my $section ( 'customers', 'materials', 'extra_elements' ) {
    if ( $self->{$section} ) {
      foreach my $section_row ( @{$self->{$section}} ) {
        $section_row->{aliases} = [ map { quotemeta } split(',\s', (lc ($section_row->{aliases})) ) ];
      }
    }
  }
  
  bless( $self, $class );
  
  return $self;
}


#**********************************************************
=head2 add_row($text) - adds row to internal storage

  Arguments:
    $text - string
    
  Returns:
    count of rows or 0 on error
    
=cut
#**********************************************************
sub add_row {
  my ($self, $text) = @_;
  
  my $analyzed = $self->analyze($text);
  
  push (@{$self->{rows}}, $analyzed);
  
  return $#{$self->{rows}};
}

#**********************************************************
=head2 get_results() - returns analyzed rows as list
  
  Returns:
    list
  
  
=cut
#**********************************************************
sub get_results {
  my ($self) = @_;
  
  return wantarray ? @{$self->{rows}} : \$self->{rows};
}


#**********************************************************
=head2 analyze($text) - analyzes given text

  Arguments:
    $text -
    
  Returns:
    hash_ref
      customers       => customer_id
      materials       => material_id
      extra_elements  => [ extra_id ]
      copies          => number
    
=cut
#**********************************************************
sub analyze {
  my ( $self, $text ) = @_;
  
  $text = lc($text);
  
  if ( my @bad_symbols = $text =~ /([^0-9a-z_\- ().])/gm ) {
    
    if ( $self->{debug} ) {
      foreach my $bad ( @bad_symbols ) {
        print "$text -- BAD : $bad\n";
      }
    }
    
    return {
      text    => $text,
      error   => 'Неправильні символи в імені файлу',
      symbols => \@bad_symbols
    };
  }
  
  my %result = (
    text           => $text,
    customers      => undef,
    materials      => undef,
    extra_elements => [ ],
    copies         => 1,
    size           => ''
  );
  
  my $PROCEED = 1;
  my $ABORT = 0;
  my $set_single = sub {
    my ($where_to_put, $value) = @_;
    $result{$where_to_put} = $value;
    $ABORT;
  };
  my $push_value = sub {
    my ($where_to_put, $value) = @_;
    unshift @{$result{$where_to_put}}, $value;
    $PROCEED;
  };
  
  my %dispatch = (
    customers      => $set_single,
    materials      => $set_single,
    extra_elements => $push_value
  );
  
  SECTION:
  foreach my $section_name ( 'customers', 'materials', 'extra_elements' ) {
    
    print "Started  section $section_name \n" if ($self->{debug});
    OBJECT:
    foreach my $object ( @{$self->{$section_name}} ) {
      
      print "Checking for object $object->{name} \n" if ($self->{debug});
      foreach my $alias ( @{$object->{aliases}} ) {
        print "$text -- $section_name -- $object->{name} -- $alias \n" if ($self->{debug});
        if ( $text =~ /($alias)/ ) {
          
          # Allow to process or break execution
          
          $dispatch{$section_name}->('matched_' . $section_name, $1);
          print "$text -- matched $alias \n" if ($self->{debug});
          
          if ( $dispatch{$section_name}->( $section_name, $object->{id}) == $ABORT ) {
            next SECTION;
          }
          else {
            next OBJECT;
          }
          
        }
      }
    }
    
  }
  
  # Check for copies
  for my $copy_alias ( '((\d+)\s?copy)', '(cop+y\s?(\d+))' ) {
    if ( $text =~ /$copy_alias/ ) {
      $result{copies} = $2;
      $result{matched_copies} = $1;
      last;
    }
  };
  
  # Check for size
  if ( $text =~ /((\d{2,})[x_](\d{2,}))/i ) {
    $result{size} = $2 . 'x' . $3;
    $result{matched_size} = $1;
  }
  elsif ( $text =~ /_(a\d)_/i ) {
    $result{size} = uc $1;
    $result{matched_size} = $1;
  }
  
  
  unless (
    $result{matched_size}
    && $result{matched_materials}
    && ($result{matched_customers} || !$self->{customers_are_required})
  ){
    $result{error} = 'Не знайдено всі поля в імені файлу';
  }
  
  return wantarray ? %result : \%result;
}
1;