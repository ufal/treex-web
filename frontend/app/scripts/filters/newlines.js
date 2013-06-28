'use strict';

angular.module('TreexWebApp')
  .filter('newlines', [function () {
    return function(text) {
      if (!text) return '';
      return text.replace(/\n/g, '<br />');
    };
  }]);
