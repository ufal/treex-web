'use strict';

angular.module('TreexWebApp')
  .directive('jqJoyride', ['$timeout', function ($timeout) {
    return function(scope, element, attrs) {
      var data = angular.extend($(element).data(), {
        autoStart: false,
        cookieMonster: true,
        template: {
          link: '<a href="javascript:" class="joyride-close-tip">X</a>',
          button: '<a href="javascript:" class="joyride-next-tip"></a>'
        }
      });
      $(element).joyride(data);
    };
  }]);
