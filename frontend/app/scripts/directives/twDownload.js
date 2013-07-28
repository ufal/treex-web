'use strict';

angular.module('TreexWebApp')
  .directive('twDownload', ['apiUrl', '$window', function (api, $window) {
    return {
      priority: 99,
      link: function(scope, elem, attrs) {
        attrs.$observe('twDownload', function(value) {
          if (!value)
            return;

          attrs.$set('href', api + value);
          elem.on('click', function(e) {
            $window.open(api + value);
            e.preventDefault();
          });
        });
      }
    };
  }]);
