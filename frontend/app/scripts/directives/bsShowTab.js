'use strict';

angular.module('TreexWebApp')
  .directive('bsShowTab', [function() {
    return {
      scope: {
        showtab: '&bsShowTab'
      },
      link: function (scope, element, attrs) {
        $(element).on('show', function(e) {
          if (attrs.bsShowTab) {
            scope.showtab();
          }
        });
        element.click(function(e) {
          e.preventDefault();
          e.stopPropagation();
          scope.$apply(function() {
            $(element).tab('show');
          });
        });
      }
    };
  }]);
