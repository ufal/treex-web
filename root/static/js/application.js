$(document).ready(function() {
    // scenarios
    // $('#scenarios-list tr').click(function(){
    //     var tr = $('tr');
    //     tr.append($('td').attr('colspan', 4));

    //     $(this).after($('tr'));
    // });

    $('#extract-url-form').submit(function(e){
        e.preventDefault();
        var url = $('#input-url').val();
        extract_text_from_url(url, function(text){
            $('#extract-error').hide();
            $('#extracted-text').text(text);
        }, function(xhr, status, error) {
            $('#extract-error')
              .html("<b>"+error+"</b><br />"+xhr.responseText)
              .show();
        });
    });

    $('.replace-input').click(function(e) {
        var $this = $(this);
        var text = $('#'+$this.data('source')).text();
        if (text) {
            $('#input').val(text);
            $this.parents('.modal').modal('hide');
        } else {
            e.preventDefault();
        }
    });

    $('.append-input').click(function(e){
        var $this = $(this);
        var text = $('#'+$this.data('source')).text();
        if (text) {
            var $input = $('#input');
            $input.val($input.val() + text);
            $this.parents('.modal').modal('hide');
        } else {
            e.preventDefault();
        }
    });
});

function extract_text_from_url(url, success, error) {
    var p = window.location.protocol || 'http:';
    var base = p  + "//" + window.location.host;
    $.ajax({ type: "POST",
             dataType: "text", /* this will avoid evaluating scripts */
             data: {
                 url : url
             },
             url: base+'/query/extract_text_from_url/',
             error: function(xhr, textStatus, errorThrown) {
                 error && error(xhr, textStatus, errorThrown);
             },
             success: function (data) {
                 success && success(data);
             }
           });
}
