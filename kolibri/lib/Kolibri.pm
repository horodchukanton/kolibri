package Kolibri;
use strict;
use warnings FATAL => 'all';
use Dancer2;
use utf8;

our $VERSION = '0.1';

use Kolibri::DB;
use HTML::Table;

require RouteMaker;

require Files;
require Customers;
require Materials;
require ExtraElements;

my %predefined_logins = (
  'john@dorian.com' => 'dorian',
  'kolibri'         => 'kolibri'
);

hook before => sub {
    
    if ( !session('user')
      && request->path !~ m{^/adminlte}
      && request->path !~ m{^/css}
      && request->path !~ m{^/fonts}
      && request->path !~ m{^/img}
      && request->path !~ m{^/js}
      && request->path !~ m{^/login} )
    {
      forward '/login', { redirect_url => request->path };
    }
  };

hook after_layout_render => sub {
    # Clear flash message
    
    if ( session('flash') ) {
      session flash => ''
    }
  };

get '/login' => sub {
    template login => { }, { layout => undef };
  };

get '/logout' => sub {
    app->destroy_session;
    
    redirect '/';
  };

post '/login' => sub {
    my $login = params->{'login'};
    my $password = params->{'password'};
    my $redir_url = params->{'redirect_url'} || '/';
    
    $predefined_logins{$login} eq $password
      or redirect '/login';
    
    session user => $login;
    set layout => 'main';
    redirect $redir_url;
  };

get '/' => sub {
    template 'index';
  };

#**********************************************************
=head2 crud_page($controller, \@template_rows, $attr) - returns template with DataTable and add/change form

  Arguments:
    $controller     - Name of Kolibri::Schema::Result::$controller, that will be used for generating
    \@template_rows - array_ref of has_ref, parameters describing entity attributes
    $attr           - additional params to use when rendering
      table    - extra HTML::Table attrs,
      template - extra vars for crud_page template rendering
    @search_params - extra Kolibri::Schema::ResultSet::search() attrs
                     see <a href="http://search.cpan.org/~ribasushi/DBIx-Class-0.082840/lib/DBIx/Class/Manual/Cookbook.pod">here</a>
    
  Returns:
   html
  
=cut
#**********************************************************
sub crud_page {
  my ($schema, $template_rows, $attr, @search_params) = @_;
  $attr //= { };
  
  my $debug = $attr->{debug} || 0;
  my $route = $attr->{controller} || '/';
  
  my @list = ();
  if ( $attr->{list} ) {
    @list = @{$attr->{list}};
  }
  else {
    my @result_list = ($schema->search( @search_params ));
    foreach my $row ( @result_list ) {
      my %hash = $row->get_columns;
      
      #      if ( $search_params[1] && ($search_params[1]->{join} || $search_params[1]->{prefetch}) ) {
      #        my $join_table = $search_params[1]->{join} || $search_params[1]->{prefetch};
      #              %hash = %hash, ($row->$join_table->search())->get_columns;
      #      };
      
      push @list, \%hash;
    }
    
    if ( $debug > 0 && $debug <= 2 ) {
      return _debug ($debug == 1)
        ? $result_list[0] || 'no rows fetched'
        : $list[0] || 'no columns';
    };
  };
  
  
  my $table = HTML::Table->new({
    headings   => [ map { $_->{name} } @{$template_rows} ],
    lang       => { map { $_->{id} => $_->{lang_name} } @{$template_rows} },
    list       => \@list,
    changeable => $route,
    % { $attr->{table} // { } }
  });
  
  my $table_view = $table->show(\&template);
  my $table_html = template $table_view->{template}, $table_view, { layout => '' };
  
  return template 'crud_page', {
      subtemplate => $table_html,
      controller  => $route,
      fields      => $template_rows,
      %{ $attr->{template} // { } }
    }, {
      layout => $attr->{layout} // 'main'
    }
}

#**********************************************************
=head2 sort_array_to_hash_by(\@array, $key)

=cut
#**********************************************************
sub sort_array_to_hash_by {
  my ($array, $key) = @_;
  
  my %hash = ();
  foreach my $element ( @{$array} ) {
    $hash{$element->{$key}} = $element
  }
  
  return wantarray ? %hash : \%hash;
}

#**********************************************************
=head2 _debug()

=cut
#**********************************************************
sub _debug {
  my ($data, $attr) = @_;
  
  require Data::Dumper;
  Data::Dumper->import();
  
  my $dumped = Dumper($data);
  
  if ( !$attr->{is_ajax} ) {
    $dumped =~ s/\n/<br>/gm;
    $dumped =~ s/\s/&nbsp;/gm;
  }
  
  return template 'debug', { d => $dumped }, { layout => ($attr->{is_ajax} ? '' : 'main' ), %{$attr} };
}


true;
