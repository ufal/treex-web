'use strict';

angular.module('TreexWebApp')
  .directive('bsActiveTab', [ '$timeout', function($timeout) {
    return {
      terminal : true,
      link: function (scope, element, attrs) {
        $timeout(function() {
          $(element).tab('show');
        });
      }
    };
  }]);
