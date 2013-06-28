'use strict';

angular.module('TreexWebApp')
  .directive('twTimer', ['$timeout', function($timeout) {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        interval: '=',
        call: '&'
      },
      controller: ['$transclude', '$element', function($transclude, $element) {
        $transclude(function(clone) {
          $element.replaceWith(clone);
        });
      }],
      compile: function(tElement, tAttrs, transclude) {

        return function(scope, elem, attrs) {
          var df = { interval: 1000, call: function() { return false; } };
          if (!scope.call) scope.call = df.call;
          if (!scope.interval) scope.interval = df.interval;

          if (scope.call() === false)
            return;

          var deferId;
          function updateLater() {
            deferId = $timeout(function() {
              if (scope.call() !== false) updateLater();
            }, scope.interval);
          }
          scope.$on('$destroy', function() {
            if (deferId) $timeout.cancel(deferId);
          });

          updateLater();
        };
      }
    };
  }]);
