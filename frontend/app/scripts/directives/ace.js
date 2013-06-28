'use strict';

angular.module('TreexWebApp')
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

        var mode = attrs.ace;
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
        read();
        editor.getSession().on('change', change);

        scope.$watch(attrs.ngModel, function() {
          // This have to be here to trigger form validation
          // I think it is an angular bug
        });

        scope.$on('$viewContentLoaded', function() {
          editor.resize();
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
