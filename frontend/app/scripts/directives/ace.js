'use strict';

angular.module('TreexWebApp')
  .directive('aceHighlight', function() {
    function loadHighlighter(input, mode, callback) {
      var EditSession = ace.require('ace/edit_session').EditSession,
          TextLayer = ace.require('ace/layer/text').Text,
          dom = ace.require('ace/lib/dom'),
          wait = 2,
          theme;

      ace.config.loadModule(['mode', mode], function() {
        var m = ace.require('ace/mode/'+mode);
        mode =  new m.Mode();
        --wait || done();
      });

      ace.config.loadModule(['theme', 'textmate'], function() {
        theme = ace.require('ace/theme/textmate');
        dom.importCssString(
          theme.cssText,
          theme.cssClass
        );
        --wait || done();
      });

      function done() {
        var session = new EditSession("");
        session.setUseWorker(false);
        session.setMode(mode);

        var textLayer = new TextLayer(document.createElement("div"));
        textLayer.setSession(session);
        textLayer.config = {
          characterWidth: 10,
          lineHeight: 20
        };

        session.setValue(input);

        var stringBuilder = [];
        var length =  session.getLength();

        for(var ix = 0; ix < length; ix++) {
          stringBuilder.push('<div class="ace_line">');
          stringBuilder.push('<span class="ace_gutter ace_gutter-cell" unselectable="on">' + ix + '</span>');
          textLayer.$renderLine(stringBuilder, ix, true, false);
          stringBuilder.push("</div>");
        }

        textLayer.destroy();

        var html = '<div class="' + theme.cssClass + '">' +
              '<div class="ace_static_highlight">' +
              stringBuilder.join("") +
              '</div>' +
              '</div>';
        callback(html);
      }
    }

    return {
      restrict: 'A',
      require: '?ngModel',
      link: function(scope, element, attrs, ngModel) {
        var mode = attrs.aceHighlight||'text';

        if (ngModel) {
          ngModel.$render = function() {
            var value = ngModel.$viewValue || '';
            loadHighlighter(value, mode, placeHtml);
          };
        } else {
          loadHighlighter($(element).text(), mode, placeHtml);
        }

        function placeHtml(html) {
          $(element)
            .html(html);
        }
      }
    };
  })
  .directive('ace', function() {
    var ACE_EDITOR_CLASS = 'ace-editor';

    function loadAceEditor(element, mode) {
      var editor = ace.edit($(element).find('.' + ACE_EDITOR_CLASS)[0]);
      editor.session.setMode("ace/mode/" + mode);
      editor.renderer.setShowPrintMargin(false);
      editor.session.setUseWrapMode(false);

      return editor;
    }

    function valid(editor) {
      return (Object.keys(editor.getSession().getAnnotations()).length == 0);
    }

    return {
      restrict: 'A',
      require: '?ngModel',
      transclude: true,
      template: '<div class="transcluded" ng-transclude></div><div class="' + ACE_EDITOR_CLASS + '"></div>',

      link: function(scope, element, attrs, ngModel) {
        var textarea = $(element).find('textarea');
        textarea.hide();

        var mode = attrs.ace||'text';
        var editor = loadAceEditor(element, mode);

        scope.ace = editor;

        if (!ngModel) return; // do nothing if no ngModel

        ngModel.$render = function() {
          var value = ngModel.$viewValue || '';
          editor.getSession().removeListener('change', change);
          editor.getSession().setValue(value);
          textarea.val(value);
          editor.getSession().on('change', change);
        };

        editor.getSession().on('changeAnnotation', function() {
          if (valid(editor)) {
            scope.$apply(read);
          }
        });

        editor.getSession().setValue(textarea.val());
        //read();
        editor.getSession().on('change', change);

        scope.$watch(attrs.ngModel, function() {
          // This have to be here to trigger form validation
          // I think it is an angular bug
        });

        function change() {
          var value = ngModel.$viewValue;
          var editorValue = editor.getSession().getValue();
          if (value != editorValue) {
            scope.$apply(function() {
              ngModel.$setViewValue(editorValue);
              textarea.val(editorValue);
            });
          }
        }

        function read() {
          ngModel.$setViewValue(editor.getValue());
          textarea.val(editor.getValue());
        }
      }
    };
  });
