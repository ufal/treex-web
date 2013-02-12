/*global angular */
'use strict';



var web = angular.module('treex-web', ['$strap.directives', 'treex-directives', 'treex-filters']);
web.config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider.
        when('/', { templateUrl: 'partials/home.html', controller: HomePageCntl }).
        when('/results', { templateUrl: 'partials/result/list.html', controller: ResultListCntl }).
        when('/result/:resultId', { templateUrl: 'partials/result/detail.html', controller: ResultDetailCntl });
    $locationProvider.html5Mode(true);
}]);


// $(document).ready(function() {

//     $('time.timeago').timeago();
//     $('.language-select').chosen({allow_single_deselect:true,placeholder_text:"Select Some Languages"});
//     $('a[rel=tooltip]').tooltip({container: 'body'});

//     $('#extract-url-form').submit(function(e){
//         e.preventDefault();
//         var url = $('#input-url').val();
//         extract_text_from_url(url, function(text){
//             $('#extract-error').hide();
//             $('#extracted-text').text(text);
//         }, function(xhr, status, error) {
//             $('#extract-error')
//               .html("<b>"+error+"</b><br />"+xhr.responseText)
//               .show();
//         });
//     });

//     $('.replace-input').click(function(e) {
//         var $this = $(this);
//         var text = $('#'+$this.data('source')).text();
//         if (text) {
//             $('#input').val(text);
//             $this.parents('.modal').modal('hide');
//         } else {
//             e.preventDefault();
//         }
//     });

//     $('.append-input').click(function(e){
//         var $this = $(this);
//         var text = $('#'+$this.data('source')).text();
//         if (text) {
//             var $input = $('#input');
//             $input.val($input.val() + text);
//             $this.parents('.modal').modal('hide');
//         } else {
//             e.preventDefault();
//         }
//     });

//     $('#compose-scenario').click(function(e){
//         e.preventDefault();
//         $('#scenario-btns').hide(0, function() {
//             $('#scenario-editor-wrap').removeClass('hide');
//             var editor = ace.edit("scenario-editor");
//             var textarea = $('#scenario');
//             textarea.hide();
//             editor.setTheme("ace/theme/dawn");
//             editor.getSession().setMode("ace/mode/perl");
//             editor.getSession().setValue(textarea.val());
//             editor.getSession().on('change', function() {
//                 textarea.val(editor.getSession().getValue());
//             });
//             editor.getSession().setUseWrapMode(false);
//             editor.focus();
//         });
//     });

//     $('.ace-editor #scenario-editor').each(function() {
//         var textarea = $('#'+$(this).data('textarea'));
//         textarea.hide();
//         var editor = ace.edit("scenario-editor");
//         editor.setTheme("ace/theme/dawn");
//         editor.getSession().setMode("ace/mode/perl");
//         editor.getSession().setValue(textarea.val());
//         editor.getSession().on('change', function() {
//             textarea.val(editor.getSession().getValue());
//         });
//         editor.getSession().setUseWrapMode(false);
//     });

//     $('#treex-pending').each(function(){
//         var $this = $(this),
//             token = $this.data('token');
//         token && poll_treex_result(token);
//     });

//     function setup_pager(pager, sentence, view) {
//         var next = $('.next-bundle', pager),
//             prev = $('.prev-bundle', pager);
//         prev.addClass('disabled');
//         $('a', next).click(function(e){
//             e.preventDefault();
//             if (view.hasNextBundle()) {
//                 view.nextBundle();
//                 set_sentence(sentence, view);
//             }
//             if (!view.hasNextBundle())
//                 next.addClass('disabled');
//             if (view.hasPreviousBundle())
//                 prev.removeClass('disabled');
//         });
//         $('a', prev).click(function(e){
//             e.preventDefault();
//             if (view.hasPreviousBundle()) {
//                 view.previousBundle();
//                 set_sentence(sentence, view);
//             }
//             if (!view.hasPreviousBundle())
//                 prev.addClass('disabled');
//             if (view.hasNextBundle())
//                 next.removeClass('disabled');
//         });
//     }

//     function set_sentence(holder, view) {
//         var sentence = view.getSentences().join("\n");
//         holder.text(sentence);
//         holder.html(holder.html().replace(/\n/g, '<br>'));
//     }

//     $('#treexview').each(function(){
//         var $this = $(this),
//             $pager = $('.pager', $this),
//             $sentence = $('.sentence', $this),
//             token = $this.data('token'),
//             p = window.location.protocol || 'http:',
//             url = p  + "//" + window.location.host + '/result/' + token + '/print';

//         Treex.loadDoc(url, function(doc) {
//             var view = Treex.TreeView('gfx-holder');
//             view.renderDocument(doc);
//             set_sentence($sentence, view);
//             $('.print-placeholder', $this).hide();
//             if (doc.bundles.length > 1) {
//                 setup_pager($pager, $sentence, view);
//                 $pager.show();
//             }
//         });
//     });

//     $('#result-tabs a[data-toggle="tab"]').on('show', function (e) {
//         var $target = $(e.target),
//             $related = $(e.relatedTarget),
//             $curr = $($target.attr('href')),
//             $prev = $($related.attr('href')),
//             $tab_content = $curr.parent();

//         if ($tab_content.height() < $curr.height()) {
//             var h = $tab_content.height() - $prev.height();
//             if ( (h + $curr.height()) > $tab_content.height() ) {
//                 $tab_content.css('height', h + $curr.height());
//             }
//         }
//     });
//     $('#result-tabs a[data-toggle="tab"]:first').tab('show');

//     $('#pick-scenario-modal').on('show', function() {
//         var language = $('#language').val(), // get language value form filter
//             $this = $(this);
//         if ($this.data('language') == language) return;
//         var p = window.location.protocol || 'http:';
//         var base = p  + "//" + window.location.host;

//         $.getJSON(base + '/scenarios/pick', { lang : language }, function(data, status) {
//             var $body = $('.modal-body', $this);
//             if (!data || !data.scenarios || data.scenarios.length == 0) {
//                 $body.html('<div class="alert alert-info">There are no scenarios available for selected language.</div>');
//                 return;
//             }
//             var $table = $('<table/>').addClass('table table-striped');
//             $table.append($('<thead><tr><th>Name</th><th>Description</th></tr></thead>'));
//             var $tbody = $('<tbody/>').appendTo($table);
//             $body.html($table);
//             $.each(data.scenarios, function(i, scenario) {
//                 var $row = $('<tr/>').addClass('rowlink'),
//                     name = $('<td/>').text(scenario.name).addClass('span2'),
//                     desc = $('<td/>').text(scenario.description);
//                 $row.append(name).append(desc);
//                 $row.data('scenario', scenario);
//                 $tbody.append($row);
//             });
//             var tr = $tbody.find('tr:has(td)');
//             tr.each(function(){
//                 var s = $(this).data('scenario');
//                 if (!s) return;
//                 $(this).find('td').click(function(){
//                     $('#scenario_id').val(s.id);
//                     $('#scenario-name').text(s.name);
//                     $('#scenario-desc').text(s.description);
//                     $('#scenario-name-wrap').removeClass('hide');
//                     $this.modal('hide');
//                 });
//             });
//         });
//     });
// });

// function extract_text_from_url(url, success, error) {
//     var p = window.location.protocol || 'http:';
//     var base = p  + "//" + window.location.host;
//     $.ajax({ type: "POST",
//              dataType: "text", /* this will avoid evaluating scripts */
//              data: {
//                  url : url
//              },
//              url: base+'/query/extract_text_from_url/',
//              error: function(xhr, textStatus, errorThrown) {
//                  error && error(xhr, textStatus, errorThrown);
//              },
//              success: function (data) {
//                  success && success(data);
//              }
//            });
// }

// function poll_treex_result(token) {
//     var p = window.location.protocol || 'http:';
//     var base = p  + "//" + window.location.host + '/result/' + token;
//     var stop = false;

//     (function poll(){
//         if (stop) return;
//         $.ajax({ url: base + '/status', success: function(data){
//             console.log("Status: " + data.status);
//             if (data.status != 'pending') {
//                 stop = true;
//                 load_tree_result(token);
//             }
//         }, dataType: "json", timeout: 4000 });
//         setTimeout(poll, 4000);
//     })();
// }

// function load_tree_result(token) {
//     $('.loading').hide();
// }
