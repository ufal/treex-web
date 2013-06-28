'use strict';

angular.module('TreexWebApp')
  .directive('bsShowTab', [function() {
    return {
      scope: {
        showtab: '&bsShowTab'
      },
      link: function (scope, element, attrs) {
        $(element).on('show', function(e) {
          if (scope.showtab) {
            scope.showtab();
            scope.$apply();
          }
        });
        element.click(function(e) {
          e.preventDefault();
          e.stopPropagation();
          $(element).tab('show');
        });
      }
    };
  }]);
