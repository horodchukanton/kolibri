/**
 * Created by Anykey on 02.07.2017.
 */
$(function () {
  
  var $table      = $('table#preview_table');
  var $table_body = $table.find('tbody');
  new BadTextBlock();
  
  var materials     = window['MATERIALS'];
  var customers     = window['CUSTOMERS'];
  var extraElements = window['EXTRA_ELEMENTS'];
  
  var analyzed = window['ANALYZED'];
  
  console.log(analyzed);
  
  var customers_select = new HashSelect('customers', customers);
  var materials_select = new HashSelect('materials', materials);
  //var extra_elements_select = new HashSelect('extraElements', extraElements);
  
  var columns_ordered = [];
  $table
      .find('thead')
      .find('th')
      .each(function (i, item) {
        columns_ordered[columns_ordered.length] = $(item).attr('id');
      });
  
  for (var i = 0; i < analyzed.length; i++) {
    var row = new PreviewTableRow(analyzed[i]);
    $table_body.append(row.getTr());
  }
  
  $('button#btn-save-results').on('click', function (e) {
    e.preventDefault();
    saveResult()
  });
  
  function saveResult() {
    var rows = [];
    
    var trs = $table_body.find('tr');
    
    for (var i = 0; i < trs.length; i++) {
      var current_row = {};
      
      var tds = $(trs[i]).find('td');
      
      for (var j = 0; j < tds.length; j++) {
        var value = $(tds[j]).data('value');
        
        console.log(columns_ordered[j], value);
        if (!value && columns_ordered[j] === 'extra_price'){
          value = 0;
        }
        
        if (typeof (value) === 'undefined') {
          $(trs[i]).addClass('bg-warning');
          $(tds[j]).addClass('bg-red');
          
          scrollToElement($(trs[i]));
          return false;
        }
        
        current_row[columns_ordered[j]] = value;
        
      }
      
      rows[rows.length] = current_row;
    }
    
    $.post('/files/upload/save', {rows: JSON.stringify(rows)}, function (data) {
      
      console.log(data);
      
      try {
        var resp = JSON.parse(data);
        
        if (resp['result'] === 'ok') {
          location.href = '/files/view';
        }
        else if (resp['result'] === 'failed') {
          //reason => $reason,
          //    row    => ($current_processed_row + 1)
          alert('При збереженні виникла помилка : '
              + resp['reason'] + ' ( рядок ' + resp['row'] + ' ).'
              + ' Виправте помилку та спробуйте знову')
        }
        
      } catch (Error) {
        alert("Error");
      }
      
    });
  }
  
  function HashSelect(name, hash) {
    this.hash = hash;
    this.name = name;
    
    this.compute = function () {
      this.$select = $('<select></select>');
      
      this.$select.append(
          '<option value="0">Не визначено</option>'
      );
      
      
      for (var option in this.hash) {
        if (!this.hash.hasOwnProperty(option)) continue;
        
        this.$select.append(
            '<option value="' + option + '">' + this.hash[option] + '</option>'
        );
        
      }
      this.$select.append(
          '<option value="-1" disabled>Створити</option>'
      );
    };
    
    this.getView = function (onchange) {
      var copy = this.$select.clone();
      
      copy.on('change', function () {
        onchange(copy)
      });
      
      return copy;
    };
    
    this.compute();
  }
  
  function SmartTdInput(value) {
    var self = this;
    
    this.$input =
        $('<input/>',
            {
              'class': 'form-control input-price',
              type   : 'text',
              value  : value
            });
    
    this.$input.on('input', function () {
      self.$input.parents('td').first().data('value', this.value);
    });
    
    return this.$input;
  }
  
  function PreviewTableRow(rawJSON) {
    
    var self = this;
    
    this.id   = $table_body.find('tr').length + 1;
    this.text = rawJSON.text;
    
    this.highlightedText = this.text;
    this.p               = rawJSON;
    
    this.calculated_to_raw_key = {
      num           : 'id',
      text          : 'text',
      customers     : 'customers',
      materials     : 'materials',
      size          : 'size',
      extra         : 'extra_elements',
      copies        : 'copies',
      material_price: 'material_price',
      area          : 'area',
    };
    
    this.highlightPart = function (text, color) {
    
    };
    
    this.getSelectFor = function (name) {
      var select;
      switch (name) {
        case 'customers' :
          select = customers_select;
          break;
        case 'materials' :
          select = materials_select;
          break;
        default:
          alert('Wrong select name :' + name);
          return ''
      }
      return select.getView(this.selectChangeCallback);
    };
    
    this.selectChangeCallback = function ($select) {
      $select.parent().data('value', $select.val());
    };
    
    this.calculateFields = function () {
      //    'matched_size'      => '210x148',
      //    'matched_materials' => 'oracal',
      //    'matched_copies'    => '1 copy',
      //    'matched_customers' => 'poligrafcenter',
      
      this.calculated = {
        num           : this.id,
        text          : this.highlightedText,
        customers     : this.p['customers']
            ? customers[this.p['customers']]
            : this.getSelectFor('customers'),
        materials     : this.p['materials']
            ? materials[this.p['materials']]
            : this.getSelectFor('materials'),
        size          : this.p.size,
        extra         : (this.p['extra_elements'] && this.p['extra_elements'].length)
            ? this.p['extra_elements'].map(function (id) {return extraElements[id]}).join(',')
            : '',
        copies        : this.p.copies,
        material_price: this.p.material_price || new SmartTdInput(this.p.material_price),
        area          : this.p.area,
        extra_price   : new SmartTdInput(this.p.extra_price)
      };
      
      return this.calculated;
    };
    
    this.getTr = function (tr_class) {
      this.calculateFields();
      
      var $tr = $('<tr></tr>', {'class': tr_class || ''});
      
      columns_ordered.forEach(function (col_key) {
        
        var value =
                self.p[self.calculated_to_raw_key[col_key]]
                || self[self.calculated_to_raw_key[col_key]];
        
        if (!value) {
          console.log(col_key, value, self.p);
        }
        
        var $td = $('<td></td>', {
              'data-value': value
            }
        )
            .html(self.calculated[col_key]);
        $tr.append($td);
      });
      
      return $tr;
    }
    
  }
  
  function SingleTextSender(text) {
    var text_to_send = text;
    var url          = '/files/upload/file/single';
    
    this.send = function (callback) {
      $.getJSON(url, {
        text: text_to_send
      }, callback)
    }
  }
  
  function BadTextBlock() {
    // Bad text modal
    var self = this;
    
    var block = $('#bad-text-block');
    
    var $bad_text_modal = $('#edit_bad_text_modal');
    $bad_text_modal.on('show.bs.modal', function (event) {
      var button      = $(event.relatedTarget);
      var text        = button.data('original-text');
      var marked_text = button.next('span.bad-text').html();
      
      $bad_text_modal.find('.modal-title').text('Виправлення некоректного тексту');
      $bad_text_modal.find('.modal-body #original-text').html(marked_text);
      $bad_text_modal.find('.modal-body #new-text').val(text);
      
      $('form#bad_text_form').one('submit', function (e) {
        e.preventDefault();
        
        var new_text = $bad_text_modal.find('.modal-body #new-text').val();
        
        new SingleTextSender(new_text).send(function (data) {
          
          if (typeof data['error'] === 'undefined') {
  
            var $new_row = new PreviewTableRow(data[0]);
            var row_tr   = $new_row.getTr('bg-teal');
  
            var api = $table.DataTable();
            
            api.rows.add(row_tr).draw();
  
            self.removeLi(button.parents('li').first(), row_tr);
  
            // Renew datatables cache
            //$table.DataTable().
            $bad_text_modal.modal('hide');
          }
          else {
            alert('Все ще не вдалось розпізнати, спробуйте ще раз')
          }
        });
      });
      
      $bad_text_modal.on('hide.bs.modal', function () {
        $('form#bad_text_form').off('submit');
      });
      
    });
    
    this.removeLi = function ($li, $tr) {
      $li.remove();
      if ($('.btn-bad-text').length < 1) {
        block.hide(200);
        
        scrollToElement($tr);
      }
    }
  }
  
  function scrollToElement($element) {
    $('html, body').animate({
      scrollTop: $element.offset().top
    }, 2000);
  }
});