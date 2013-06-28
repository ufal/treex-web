'use strict';

angular.module('TreexWebApp')
  .directive('bsActiveTab', [function() {
    return {
      terminal : true,
      link: function (scope, element, attrs) {
        $(element).tab('show');
      }
    };
  }]);
