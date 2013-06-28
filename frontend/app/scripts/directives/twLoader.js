'use strict';

angular.module('TreexWebApp')
  .directive('twLoader', [function () {
    return function(scope, elm, attrs) {
      elm.html('<img src="images/ajax-loader.gif" title="Loading..." />');
    };
  }]);
