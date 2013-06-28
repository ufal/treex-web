'use strict';

angular.module('TreexWebApp')
  .directive('appVersion', [function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the appVersion directive');
      }
    };
  }]);
