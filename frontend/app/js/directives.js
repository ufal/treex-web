'use strict';

/* Directives */

angular.module('treex-directives', []).
    directive('twView', ['$rootScope', function($rootScope) {
        return {
            restrict: 'A',
            transclude: true,
            scope: {
                result: '=twView'
            },
            template: '<div id="treex-view"><div ng-transclude></div><div id="gfx-holder"></div></div>',
            controller: ['$element', function($element) {
                this.$view = null;
                this.$doc = null;

                this.nextBundle = function() {
                    var view = this.$view;
                    if (view && view.hasNextBundle()) {
                        view.nextBundle();
                        this.change();
                    }
                };

                this.previousBundle = function() {
                    var view = this.$view;
                    if (view && view.hasPreviousBundle()) {
                        view.previousBundle();
                        this.change();
                    }
                };

                this.change = function(fn) {
                    if (fn) {
                        $element.bind('change', fn);
                    } else {
                        $element.trigger('change');
                    }
                };
            }],
            link : function(scope, element, attrs, cntl) {
                scope.$watch('result.job.status', function(value) {
                    if (cntl.$view != null || value != 'completed') return;

                    var result = scope.result;
                    result.$print().then(function(data) {
                        cntl.$doc = Treex.Document.fromJSON(data);
                        cntl.$view = Treex.TreeView('gfx-holder');
                        cntl.$view.renderDocument(cntl.$doc);
                        $rootScope.$broadcast('treex:rendered');
                    });
                });
            }
        };
    }]).
    directive('twViewPager', function() {
        return {
            restrict: 'A',
            require: '^twView',
            link : function(scope, element, attrs, cntl) {
                cntl.change(function() { // on view change
                    if (cntl.$view) {
                        scope.hasPreviousBundle = cntl.$view.hasPreviousBundle();
                        scope.hasNextBundle = cntl.$view.hasNextBundle();
                        scope.$apply();
                    }
                });
                element.find('.prevBundle').bind('click', function(e) {
                    e.stopPropagation();
                    cntl.previousBundle();
                });
                element.find('.nextBundle').bind('click', function(e) {
                    e.stopPropagation();
                    cntl.nextBundle();
                });

                scope.$on('treex:rendered', function() {
                    if (cntl.$doc && cntl.$doc.bundles.length > 1) {
                        element.show();
                        scope.hasPreviousBundle = cntl.$view.hasPreviousBundle();
                        scope.hasNextBundle = cntl.$view.hasNextBundle();
                    } else {
                        element.hide();
                    }
                });
            }
        };
    }).
    directive('twViewSentence', function() {
        return {
            restrict: 'A',
            require: '^twView',
            link : function(scope, element, attrs, cntl) {
                cntl.change(function() { // on view change
                    if (cntl.$view) {
                        scope.sentence = cntl.$view.getSentences().join("\n");
                        scope.$apply();
                    }
                });
                scope.$on('treex:rendered', function() {
                    scope.sentence = cntl.$view.getSentences().join("\n");
                });

            }
        };
    }).
    directive('twViewLoading', function() {
        return {
            restrict: 'A',
            require: '^twView',
            link : function(scope, element, attrs, cntl) {
                scope.$on('treex:rendered', function() {
                    element.hide();
                });
            }
        };
    }).
    directive('ace', function() {
        var ACE_EDITOR_CLASS = 'ace-editor';

        function loadAceEditor(element, mode) {
            var editor = ace.edit($(element).find('.' + ACE_EDITOR_CLASS)[0]);
            editor.session.setMode("ace/mode/" + mode);
            editor.renderer.setShowPrintMargin(false);
            editor.session.setUseWrapMode(false);

            return editor;
        }

        function valid(editor) {
            return (Object.keys(editor.getSession().getAnnotations()).length == 0);
        }

        return {
            restrict: 'A',
            require: '?ngModel',
            transclude: true,
            template: '<div class="transcluded" ng-transclude></div><div class="' + ACE_EDITOR_CLASS + '"></div>',

            link: function(scope, element, attrs, ngModel) {
                var textarea = $(element).find('textarea');
                textarea.hide();

                var mode = attrs.ace;
                var editor = loadAceEditor(element, mode);

                scope.ace = editor;

                if (!ngModel) return; // do nothing if no ngModel

                ngModel.$render = function() {
                    var value = ngModel.$viewValue || '';
                    editor.getSession().setValue(value);
                    textarea.val(value);
                };

                editor.getSession().on('changeAnnotation', function() {
                    if (valid(editor)) {
                        scope.$apply(read);
                    }
                });

                editor.getSession().setValue(textarea.val());
                read();

                function read() {
                    ngModel.$setViewValue(editor.getValue());
                    textarea.val(editor.getValue());
                }
            }
        };
    }).
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
                var clear = false,
                    selectCntl = cntls[0],
                    modelCntl = cntls[1];

                modelCntl.$render = function() {
                    if (!modelCntl.$modelValue)
                        element.select2('val', null, false);
                };

                element.bind('change', function() {
                    var val = element.val();
                    element.select2('val', !val ? null : val, false);
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
    directive('fadey', function() {
        return {
            restrict: 'A',
            link: function(scope, elm, attrs) {
                var duration = parseInt(attrs.fadey);
                if (isNaN(duration)) {
                    duration = 500;
                }
                elm.hide();
                elm.fadeIn(duration);

                scope.destroy = function(complete) {
                    elm.fadeOut(duration, function() {
                        if (complete) {
                            complete.apply(scope);
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
