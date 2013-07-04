'use strict';

angular.module('TreexWebApp')
  .factory('siteError', [ '$rootScope', function(scope) {

    return {
      report: function(error) {
        scope.siteError = error;
      }
    };
  }]);
