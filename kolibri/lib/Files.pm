use strict;
use warnings FATAL => 'all';
use JSON::XS;
use utf8;
use Data::Dumper;

my $json = JSON::XS->new->utf8(0);

my @template_rows = (
  {
    name      => 'id',
    id        => 'id',
    type      => 'hidden',
    lang_name => '#'
  },
  {
    name      => 'uploaded',
    id        => 'uploaded',
    type      => 'static',
    lang_name => 'Додано'
  },
  {
    name      => 'name',
    id        => 'name',
    type      => 'text',
    lang_name => 'Назва'
  },
  {
    name      => 'customer',
    id        => 'customer',
    type      => 'select',
    lang_name => 'Замовник'
  },
  {
    name      => 'material',
    id        => 'material',
    type      => 'select',
    lang_name => 'Матеріал'
  },
  {
    name      => 'size',
    id        => 'size',
    type      => 'static',
    lang_name => 'Розмір'
  },
  {
    name      => 'area',
    id        => 'area',
    type      => 'static',
    lang_name => 'Площа'
  },
  {
    name      => 'material_price',
    id        => 'material_price',
    type      => 'static',
    lang_name => 'Ціна по матеріалу'
  },
  {
    name      => 'extra_elements',
    id        => 'extra_elements',
    type      => 'static',
    lang_name => 'Додаткові елементи'
  },
  {
    name      => 'extra_price',
    id        => 'extra_price',
    type      => 'text',
    lang_name => 'Додаткова ціна'
  },
  {
    name      => 'copies',
    id        => 'copies',
    type      => 'text',
    lang_name => 'Копій'
  },
  {
    name      => 'price',
    id        => 'price',
    type      => 'static',
    lang_name => 'Кінцева ціна'
  }
);
my $SCHEMA = schema('File');
my $ROUTE = '/files';
my $NAME = 'Файли';

# Create
post $ROUTE => route_create($SCHEMA, $ROUTE);

# Preview single
get $ROUTE . '/change/:id' => route_preview_single($SCHEMA, $ROUTE, $NAME, \@template_rows);

# Change single
post $ROUTE . '/change' => sub {
    my $item_to_change = $SCHEMA->find( params->{id} );
    
    if ( $item_to_change ) {
      my @keys = map { $_->{id} } @template_rows;
      my %values = (params);
      
      my %values_we_care = map { $_ => $values{$_}  } grep { defined $values{$_} } @keys;
      
      my %current = $item_to_change->get_columns();
      
      # Get material price
      my $material_price = schema('Material')->find({ id => $values_we_care{material} })->price_per_m;
      
      # Recalculate price
      my $calculated = calculate_single({ %current, %values_we_care }, {
          price_per_m => $material_price
        });
      
      if ( !$calculated->{price} ) {
        $calculated->{price} = (($calculated->{material_price} || 0) + ($calculated->{extra_price} || 0)) * $calculated->{copies};
        # TODO: Save to table
      }
      
      my %updated = map { $_ => $calculated->{$_}  } grep { defined $values{$_} } @keys;
      
      $item_to_change->update( \%updated );
      session flash => $NAME . ' змінено';
    }
    else {
      session flash => $NAME . ' для зміни не знайдено';
    }
    
    redirect $ROUTE . '/view';
  };

# Delete
get $ROUTE . '/delete/:id' => route_remove($SCHEMA, $ROUTE, $NAME);

get '/files' => sub {
    forward '/files/view';
    #    template 'index', { page_header => 'Файли' };
  };

get '/files/upload' => sub {
    template 'files/upload', { page_header => 'Файли' }
  };

post '/files/upload/file' => sub {
    
    my $upload_obj = request->upload('file');
    my $customers_are_required = param('CUSTOMERS_REQUIRED');
    
    my $content = $upload_obj->content;
    
    # Translate cyrillic 'x' to latin 'x'
    $content =~ s/х/x/gm;
    
    my ($without_error, $with_error) = analyze_uploaded_file_content($content, {
        CUSTOMERS_REQUIRED => $customers_are_required
      });
    
    my @bad_rows = transform_bad_rows(@{$with_error});
    
    my $id_name = sub {
      my %columns = $_[0]->get_columns;
      { $columns{id} => $columns{name} }
    };
    
    my %materials_hash
      = map {$id_name->($_)} schema('Material')->search(undef, { columns => [ 'id', 'name' ] });
    
    my %customers_hash
      = map {$id_name->($_)} schema('Customer')->search(undef, { columns => [ 'id', 'name' ] });
    
    my %extra_elements_hash
      = map {$id_name->($_)} schema('ExtraElement')->search(undef, { columns => [ 'id', 'name' ] });
    
    my @price_calculated = calculate_prices(@{$without_error});
    
    #    return _debug($without_error[0], {is_ajax => request->is_ajax});
    
    
    return template 'files/analyzed_preview', {
        ANALYZED            => $json->encode(\@price_calculated),
        
        MATERIALS_HASH      => $json->encode(\%materials_hash),
        CUSTOMERS_HASH      => $json->encode(\%customers_hash),
        EXTRA_ELEMENTS_HASH => $json->encode(\%extra_elements_hash),
        
        customers_required  => $customers_are_required,
        bad_names           => \@bad_rows,
        has_bad_names       => scalar(@bad_rows),
      };
  };

any '/files/upload/file/single' => sub {
    my $text = params->{text};
    
    my ($analyzed, $with_error) = analyze_uploaded_file_content($text);
    my @calculated = calculate_prices(@{$analyzed});
    
    return $json->encode($with_error ? \@calculated : $with_error);
  };

post '/files/upload/save' => sub {
    
    my $rows_json = params->{rows};
    my $rows = $json->decode($rows_json);
    
    print Dumper $rows;
    
    my $File = schema('File');
    
    my $current_processed_row = 0;
    my $save_files = sub {
      foreach my $row ( @{$rows} ) {
        
        my %table_row = (
          name           => $row->{text},
          customer       => $row->{customers},
          material       => $row->{materials},
          extra_elements => $row->{extra},
          size           => $row->{size},
          copies         => $row->{copies},
          material_price => $row->{material_price},
          extra_price    => $row->{extra_price},
          area           => $row->{area},
        
        );
        
        $File->create(\%table_row);
        $current_processed_row++;
      }
    };
    
    eval {
      db()->txn_do($save_files)
    };
    if ( $@ ) {
      
      my $reason = "$@";
      if ( $reason =~ /Column '(.*)' cannot be null/ ) {
        
        $reason = "Колонка '$1' повинна бути заповнена";
      }
      
      return $json->encode({
        result => 'failed',
        reason => $reason,
        row    => ($current_processed_row + 1)
      });
    }
    
    session flash => 'Список збережено, додано ' . scalar(@{$rows}) . ' елементів';
    
    return $json->encode({
      result => 'ok'
    });
    
    return _debug(\@{$rows}, { is_ajax => request->is_ajax });
  };

get '/files/view' => sub {
    
    # Get list of files
    my @files_rs = ($SCHEMA->search());
    my $Materials = schema('Material');
    my $Customers = schema('Customer');
    my $ExtraElements = schema('ExtraElement');
    
    my %customer_names = map { $_->id() => $_->name() } ($Customers->search() );
    my @rows = ();
    foreach my $rs ( @files_rs ) {
      my %file = $rs->get_columns();
      
      # This part can be replaced with JOIN
      #      my $customer_name = $Customers->find($file{customer})->name;
      my $customer_name = $customer_names{$file{customer}};
      my $material_name = $Materials->find($file{material})->name;
      
      my @extra_element_ids = split(',\s', $file{extra_elements});
      my $extra_elements = join(', ',
        map {
          $ExtraElements->find($_)->name
        } @extra_element_ids
      );
      
      if ( !$file{price} ) {
        $file{price} = (($file{material_price} || 0) + ($file{extra_price} || 0)) * $file{copies};
        # TODO: Save to table
      }
      
      push(@rows, {
          %file,
          #          text => $file{name},
          customer       => $customer_name,
          material       => $material_name,
          extra_elements => $extra_elements,
        });
    }
    
    #    return _debug(\@rows);
    
    my $controls = template 'files/table_export_controls', {
        customers => $json->encode( [ sort values %customer_names ] )
      },
      {
        layout => undef
      };
    
    return crud_page($SCHEMA, \@template_rows, {
        controller => '/files',
        template   => {
          without_add     => 1,
          with_delete_all => 1,
          heading         => $NAME,
          controls        => $controls
        },
        table      => {
          #          subtemplate => $controls,
          headings => [
            #            'id',
            'name',
            'customer',
            'material',
            #                        'size',
            'area',
            'material_price',
            'extra_elements',
            'extra_price',
            'copies',
            'price'
          ]
        },
        list       => \@rows
      });
  };

#**********************************************************
=head2 analyze_uploaded_file_content()

=cut
#**********************************************************
sub analyze_uploaded_file_content {
  my ($content, $attr) = @_;
  
  my %data = ();
  
  foreach my $name ( 'Customer', 'ExtraElement', 'Material' ) {
    my @rows = (schema($name)->search(undef, { columns => [ 'id', 'name', 'aliases' ] }));
    my @hash_refs = map { { $_->get_columns } } @rows;
    
    $data{$name} = \@hash_refs;
  }
  
  require Kolibri::Filename::Analyzer;
  Kolibri::Filename::Analyzer->import();
  
  my $analyzer = Kolibri::Filename::Analyzer->new({
    customers              => $data{Customer},
    extra_elements         => $data{ExtraElement},
    materials              => $data{Material},
    customers_are_required => $attr->{CUSTOMERS_REQUIRED}
    #    debug => 1,
  });
  
  my @rows = split(/(?:\r\n)|\n/, $content);
  foreach my $row ( @rows ) {
    next if ($row eq 'list.txt' || $row eq 'list_files.bat');
    $analyzer->add_row($row);
  }
  
  my @analyzed = $analyzer->get_results;
  
  my @without_error = ();
  my @with_error = ();
  
  foreach my $row ( @analyzed ) {
    if ( defined $row->{error} ) {
      push(@with_error, $row);
    }
    else {
      push(@without_error, $row);
    }
  }
  
  return wantarray ? ( \@without_error, \@with_error ) : [ \@without_error, \@with_error ];
}

#**********************************************************
=head2 calculate_prices(@analyzed)

=cut
#**********************************************************
sub calculate_prices {
  my (@rows) = @_;
  
  my %data = ();
  
  foreach my $name ( 'Customer', 'ExtraElement', 'Material' ) {
    my @rs = (schema($name)->search());
    my @hash_refs = map { { $_->get_columns } } @rs;
    
    $data{$name} = \@hash_refs;
  }
  
  my %material_by_id = sort_array_to_hash_by($data{'Material'}, 'id');
  #  my %customer_by_id = sort_array_to_hash_by($data{'Customer'}, 'id');
  #  my %extra_element_by_id = sort_array_to_hash_by($data{'ExtraElement'}, 'id');
  
  my @calculated = map {
    
    my %params_for_row = (
      price_per_m => 0
    );
    
    my $material = $_->{materials};
    if ( $material && $material_by_id{$material} ) {
      $params_for_row{price_per_m} = $material_by_id{$material}->{price_per_m}
    }
    
    calculate_single($_, \%params_for_row);
    
  } @rows;
  
  return wantarray ? @calculated : \@calculated;
}

#**********************************************************
=head2 calculate_single($row, $attr)

=cut
#**********************************************************
sub calculate_single {
  my ($row, $attr) = @_;
  print Dumper $row;
  
  my %predefined_area_constants = (
    'A0' => '1189x841',
    'A1' => '841x594',
    'A2' => '594x420',
    'A3' => '420x297',
    'A4' => '297x210',
    'A5' => '210x148',
    'A6' => '148x105',
    'A7' => '105x74',
  );
  
  # Calculate area
  $row->{area} = do {
    
    $row->{size_mm} = $predefined_area_constants{$row->{size}} || $row->{size};
    
    my ($width, $length) = split('x', $row->{size_mm});
    
    ($width && $length)
      ? sprintf("%.4f", $width * $length * 0.000001)
      : 0;
  };
  
  # Calculate material price
  if ($row->{area} < 18){
    $row->{material_price} = $row->{area} * $attr->{price_per_m};
  }
  else {
    $row->{material_price} = undef;
  }
  
  my $has_extra = ( $row && $row->{extra_elements} );
  $row->{extra_price} //= ($has_extra)
    ? undef
    : '0.00';
  
  return $row;
}


#**********************************************************
=head2 transform_bad_rows(@bad_rows)

=cut
#**********************************************************
sub transform_bad_rows {
  my (@bad_rows) = @_;
  
  my @result = ();
  foreach my $errornous ( @bad_rows ) {
    my $text_2 = $errornous->{text};
    
    if ( $errornous->{symbols} ) {
      my @bad_symbols = @{$errornous->{symbols}};
      
      foreach my $symb ( @bad_symbols ) {
        my $quoted = quotemeta $symb;
        $text_2 =~ s/$quoted/<mark class='text-bold text-underline'>$symb<\/mark>/;
      }
    }
    
    push(@result, { text => $text_2, original_text => $errornous->{text} })
  }
  
  return wantarray ? @result : \@result;
}
1;