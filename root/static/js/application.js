$(document).ready(function() {
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

    $('#compose-scenario').click(function(e){
        e.preventDefault();
        $('#scenario-btns').hide(0, function() {
            $('#scenario-editor-wrap').removeClass('hide');
            var editor = ace.edit("scenario-editor");
            var textarea = $('#scenario');
            editor.setTheme("ace/theme/dawn");
            editor.getSession().setMode("ace/mode/perl");
            editor.getSession().setValue(textarea.val());
            editor.getSession().on('change', function() {
                textarea.val(editor.getSession().getValue());
            });
            editor.getSession().setUseWrapMode(false);
            editor.focus();
        });
    });

    $('#treex-pending').each(function(){
        var $this = $(this);
        var token = $this.data('token');
        token && poll_treex_result(token);
    });

    $('#treexview').each(function(){
        var $this = $(this);
        var token = $this.data('token');
        var p = window.location.protocol || 'http:';
        var url = p  + "//" + window.location.host + '/result/' + token + '/print';

        Treex.loadDoc(url, function(data) {
            var view = Treex.TreeView('gfx-holder');
            view.renderBundle(data.bundles[0]);
        });
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

function poll_treex_result(token) {
    var p = window.location.protocol || 'http:';
    var base = p  + "//" + window.location.host + '/result/' + token;
    var stop = false;

    (function poll(){
        if (stop) return;
        $.ajax({ url: base + '/status', success: function(data){
            console.log("Status: " + data.status);
            if (data.status != 'pending') {
                stop = true;
                load_tree_result(token);
            }
        }, dataType: "json", timeout: 4000 });
        setTimeout(poll, 4000);
    })();
}

function load_tree_result(token) {
    $('.loading').hide();
}
