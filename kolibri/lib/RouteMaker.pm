#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use utf8;

sub route_show_list {
  my ( $schema, $route, $name, $template_rows, $attr ) = @_;
  
  return sub {
    return crud_page(
      $schema,
      $template_rows,
      {
        controller => $route,
        template   => {
          heading => $name
        },
        %{ $attr // { } }
      }
    );
  };
}

sub route_create {
  my ( $schema, $route ) = @_;
  
  return sub {
    if ( $schema->create( { params } ) ) {
      session flash => 'Добавлено новий елемент';
    }
    
    redirect $route;
  };
}

sub route_preview_single {
  my ( $schema, $route, $name, $template_rows ) = @_;
  
  return sub {
    my $item_to_change = $schema->find( params->{id} );
    
    return template 'form', {
        fields      => $template_rows,
        item        => $item_to_change,
        caption     => $name,
        
        controller  => $route . '/change',
        show_submit => 1,
        submit_name => 'Зберегти'
      };
    
  };
}

sub route_change {
  my ( $schema, $route, $name, $template_rows ) = @_;
  
  return sub {
    my $item_to_change = $schema->find( params->{id} );
    
    if ( $item_to_change ) {
      my @keys = map { $_->{id} } @{$template_rows};
      my %values = (params);
      
      my %values_we_care = map { $_ => $values{$_} } @keys;
      
      $item_to_change->update( { %values_we_care } );
      session flash => $name . ' змінено';
    }
    else {
      session flash => $name . ' для зміни не знайдено';
    }
    
    redirect $route;
  };
}

sub route_remove {
  my ( $schema, $route, $name ) = @_;
  
  return sub {
    my $param = params->{id};
    
    if ( $param && $param eq 'all' ) {
      $schema->delete_all;
      session flash => "Всі " . lc $name . ' видалено';
      redirect $route;
    }
    
    my $item_to_delete = $schema->find( params->{id} );
    if ( $item_to_delete ) {
      $item_to_delete->delete();
      session flash => $name . ' видалено';
    }
    else {
      session flash => $name
          . ' для видалення не знайдено';
    }
    
    redirect $route;
  };
}

1;
