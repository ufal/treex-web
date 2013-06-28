'use strict';

angular.module('TreexWebApp')
  .directive('bsRowlink', ['$location', function($location) {
    return function(scope, element, attrs) {
      attrs.$observe('bsRowlink', function(value) {
        if (!value) return;

        function handler() { scope.$apply(function(){ $location.path(value); }); }

        $(element).find('td').not('.nolink').
          unbind('click', handler).
          bind('click', handler);
      });
      $(element).addClass('rowlink');
    };
  }]);
