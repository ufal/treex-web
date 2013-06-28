'use strict';

angular.module('TreexWebApp')
  .filter('noHtml', [function () {
    return function(text) {
      if (!text) return '';
      return text
        .replace(/&/g, '&amp;')
        .replace(/>/g, '&gt;')
        .replace(/</g, '&lt;');
    };
  }]);
