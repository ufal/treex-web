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
        var $this = $(this),
            token = $this.data('token');
        token && poll_treex_result(token);
    });

    function setup_pager(pager, sentence, view) {
        var next = $('.next-bundle', pager),
            prev = $('.prev-bundle', pager);
        prev.addClass('disabled');
        $('a', next).click(function(e){
            e.preventDefault();
            if (view.hasNextBundle()) {
                view.nextBundle();
                set_sentence(sentence, view);
            }
            if (!view.hasNextBundle())
                next.addClass('disabled');
            if (view.hasPreviousBundle())
                prev.removeClass('disabled');
        });
        $('a', prev).click(function(e){
            e.preventDefault();
            if (view.hasPreviousBundle()) {
                view.previousBundle();
                set_sentence(sentence, view);
            }
            if (!view.hasPreviousBundle())
                prev.addClass('disabled');
            if (view.hasNextBundle())
                next.removeClass('disabled');
        });
    }

    function set_sentence(holder, view) {
        var sentence = view.getSentences().join("\n");
        holder.text(sentence);
        holder.html(holder.html().replace(/\n/g, '<br>'));
    }

    $('#treexview').each(function(){
        var $this = $(this),
            $pager = $('.pager', $this),
            $sentence = $('.sentence', $this),
            token = $this.data('token'),
            p = window.location.protocol || 'http:',
            url = p  + "//" + window.location.host + '/result/' + token + '/print';

        Treex.loadDoc(url, function(doc) {
            var view = Treex.TreeView('gfx-holder');
            view.renderDocument(doc);
            set_sentence($sentence, view);
            $('.print-placeholder', $this).hide();
            if (doc.bundles.length > 1) {
                setup_pager($pager, $sentence, view);
                $pager.show();
            }
        });
    });

    $('#result-tabs a[data-toggle="tab"]').on('show', function (e) {
        var $target = $(e.target),
            $related = $(e.relatedTarget),
            $curr = $($target.attr('href')),
            $prev = $($related.attr('href')),
            $tab_content = $curr.parent();

        if ($tab_content.height() < $curr.height()) {
            var h = $tab_content.height() - $prev.height();
            if ( (h + $curr.height()) > $tab_content.height() ) {
                $tab_content.css('height', h + $curr.height());
            }
        }
    });
    $('#result-tabs a[data-toggle="tab"]:first').tab('show');
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
