'use strict';

/* Directives */

angular.module('treex-directives', []).
    directive('twTimer', ['$timeout', function($timeout) {
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
    }]).
    directive('bsRowlink', ['$location', function($location) {
        return function(scope, element, attrs) {
            attrs.$observe('bsRowlink', function(value) {
                console.log(value);
                if (!value) return;

                function handler() { scope.$apply(function(){ $location.path(value); }); }

                $(element).find('td').not('.nolink').
                    unbind('click', handler).
                    bind('click', handler);
            });
            $(element).addClass('rowlink');
        };
    }]).
    directive('jqTimeago', function() {
        return function(scope, element, attrs) {
            attrs.$observe('datetime', function(value){
                if (!value) return;
                $(element).timeago();
            });
        };
    }).
    directive('appVersion', ['version', function(version) {
        return function(scope, elm, attrs) {
            elm.text(version);
        };
    }]);
