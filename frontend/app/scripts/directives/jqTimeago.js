'use strict';

angular.module('TreexWebApp')
  .directive('jqTimeago', [function () {
    return function(scope, element, attrs) {
      attrs.$observe('datetime', function(value){
        if (!value) return;
        $(element).timeago();
      });
    };
  }]);
