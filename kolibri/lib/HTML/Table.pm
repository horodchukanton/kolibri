package HTML::Table;
use strict;
use warnings FATAL => 'all';

use Template::Toolkit;

#**********************************************************
=head2 new($attr) - constructor for HTML::Table

=cut
#**********************************************************
sub new {
  my $class = shift;
  
  my ($attr) = @_;
  
  my $self = {
    load_script => 0,
    %{$attr // { } }
  };
  
  bless( $self, $class );
  
  if ($attr->{list}){
    $self->set_list($attr->{list})
  }
  
  return $self;
}

#**********************************************************
=head2 set_list($list) - processes list to internal structure

  Arguments:
    $list -
    
  Returns:
    $self
    
=cut
#**********************************************************
sub set_list {
  my ($self, $list) = @_;
  
  return $self if ( !$list || !ref $list || !scalar @{$list} );
  
  my $keys = $self->{headings} || [ sort keys %{$list->[0]} ];
  
  
  $self->{rows} = [ ];
  foreach my $row ( @{$list} ) {
    
    my @values = @{$row}{@{$keys}};
    if ($self->{changeable} && $row->{id}){
      push @values,
        qq{
        <div class="btn-group btn-group-xs">
        <a type="button" id="btn_change" href='$self->{changeable}/change/$row->{id}' class="btn btn-info">
          <span class="glyphicon glyphicon-pencil"></span>
        </a>
        <a type="button" id="btn_remove" href='$self->{changeable}/delete/$row->{id}' class="btn btn-danger">
          <span class="glyphicon glyphicon-remove"></span>
        </a>
        </div>
       };
    }
    
    push (@{$self->{rows}}, \@values);
  }
  
  $self->{headings} =  $keys;
  if ($self->{changeable}){
    push (@{$self->{headings}}, '-');
  }
  
  return $self;
}

#**********************************************************
=head2 show($attr) -

  Arguments:
    $attr -
    
  Returns:
  
  
=cut
#**********************************************************
sub show {
  my ($self, $template_code_ref) = @_;
  
  $self->{load_script}++;
  
  
  return {
    template => 'datatable.tt',
    table    => { %$self }
    # MAYBE: just return self?
    #      load_script => $self->{load_script}++,
    #      headings    => $self->{headings},
    #      rows        => $self->{rows}
    #    }
  };
}



1;