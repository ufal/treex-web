'use strict';

/* Directives */

angular.module('treex-directives', []).
    directive('bsActivetab', function() {
        return {
            terminal : true,
            link: function (scope, element, attrs) {
                $(element).tab('show');
            }
        };
    }).
    directive('bsShowtab', function() {
        return {
            scope: {
                showtab: '&bsShowtab'
            },
            link: function (scope, element, attrs) {
                $(element).on('show', function(e) {
                    if (scope.showtab) scope.showtab();
                });
                element.click(function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(element).tab('show');
                });
            }
        };
    }).
    directive('bsSelect2', ['$timeout', function($timeout) {
        return {
            require: ['select', 'ngModel'],
            link: function(scope, element, attrs, cntls) {
                if (!cntls[1]) return;
                var selectCntl = cntls[0],
                    modelCntl = cntls[1];

                element.bind('change', function() {
                    element.select2('val', element.val());
                });

                if (selectCntl.databound) {
                    scope.$watch(selectCntl.databound, function(value) {
                        if (value === undefined) return;
                        $timeout(function() {
                            element.trigger('change');
                        });
                    });
                }

                element.select2(element.data());
            }
        };
    }]).
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
    directive('twLoader', function() {
        return function(scope, elm, attrs) {
            elm.html('<img src="img/ajax-loader.gif" title="Loading..." />');
        };
    }).
    directive('twIf', function() {
        return {
            transclude: 'element',
            priority: 1000,
            terminal: true,
            restrict: 'A',
            compile: function (element, attr, transclude) {
                return function (scope, element, attr) {

                    var childElement;
                    var childScope;

                    scope.$watch(attr['twIf'], function (newValue) {
                        if (childElement) {
                            childElement.remove();
                            childElement = undefined;
                        }
                        if (childScope) {
                            childScope.$destroy();
                            childScope = undefined;
                        }

                        if (newValue) {
                            childScope = scope.$new();
                            transclude(childScope, function (clone) {
                                childElement = clone;
                                element.after(clone);
                            });
                        }
                    });
                };
            }
        };
    }).
    directive('appVersion', ['version', function(version) {
        return function(scope, elm, attrs) {
            elm.text(version);
        };
    }]);
