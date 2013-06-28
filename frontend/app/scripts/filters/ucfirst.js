'use strict';

angular.module('TreexWebApp')
  .filter('ucfirst', [function () {
    return function(text) {
      return String(text).charAt(0).toUpperCase() + String(text).slice(1);
    };
  }]);
