'use strict';

/* Directives */

angular.module('treex-directives', []).
    directive('twView', ['$rootScope', function($rootScope) {
        return {
            restrict: 'A',
            scope: {
                result: '=twView'
            },
            controller: ['$element', function($element) {
                this.$view = null;
                this.$sentence = null;
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
                        cntl.$view = Treex.TreeView(element[0]);
                        cntl.$doc = Treex.Document.fromJSON(data);
                        cntl.$view.init(cntl.$doc);
                        if (cntl.$sentence)
                            cntl.$view.description(cntl.$sentence);
                        cntl.$view.drawBundle();
                        $rootScope.$broadcast('treex:rendered');
                    }, function(error) {
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
                cntl.$sentence = element[0];
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
                    editor.getSession().removeListener('change', change);
                    editor.getSession().setValue(value);
                    textarea.val(value);
                    editor.getSession().on('change', change);
                };

                editor.getSession().on('changeAnnotation', function() {
                    if (valid(editor)) {
                        scope.$apply(read);
                    }
                });

                editor.getSession().setValue(textarea.val());
                read();
                editor.getSession().on('change', change);

                scope.$watch(attrs.ngModel, function() {
                    // This have to be here to trigger form validation
                    // I think it is an angular bug
                });

                scope.$on('$viewContentLoaded', function() {
                    editor.resize();
                });

                function change() {
                    var value = ngModel.$viewValue;
                    var editorValue = editor.getSession().getValue();
                    if (value != editorValue) {
                        scope.$apply(function() {
                            ngModel.$setViewValue(editorValue);
                            textarea.val(editorValue);
                        });
                    }
                }

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
                    modelCntl = cntls[1],
                    isMultiple = (attrs.multiple !== undefined);

                // watch the model for programmatic changes
                modelCntl.$render = function() {
                    var val = !modelCntl.$viewValue ? (isMultiple ? [] : null) : angular.copy(modelCntl.$viewValue);
                    element.select2('val', val, true);
                };

                if (selectCntl.databound) {
                    scope.$watch(selectCntl.databound, function(value) {
                        element.select2('val', !value ? (isMultiple ? [] : null) : value, false);
                    });
                }
                element.select2(element.data());
                modelCntl.$render();
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
    directive('validateSameAs', ['$parse', function($parse) {
        return {
            require: 'ngModel',
            link: function(scope, elm, attrs, cntl) {
                cntl.$parsers.unshift(function(viewValue) {
                    var value = attrs['validateSameAs'];
                    if (!value) return;
                    var valueGet = $parse(value);
                    if (valueGet(scope) == viewValue) {
                        cntl.$setValidity('same', true);
                        return viewValue;
                    } else {
                        cntl.$setValidity('same', false);
                        return undefined;
                    }
                });
            }
        };
    }]).
    directive('emailAvailable', [ '$timeout', 'User', function($timeout, User) {
        var promise;
        return {
            require: 'ngModel',
            link: function(scope, elm, attrs, cntl) {
                cntl.$parsers.unshift(function(viewValue) {
                    if (promise) $timeout.cancel(promise);
                    promise = $timeout(function() {
                        User.emailAvailable(viewValue).then(function(available) {
                            console.log(available);
                            cntl.$setValidity('available', available);
                        }, function() {
                            cntl.$setValidity('available', true);
                            cntl.$setValidity('email', false);
                        });
                    }, 200);
                    return viewValue;
                });
            }
        };
    }])
    .directive('ngTable', function($compile, $parse) {
        var template = '<thead> \
            <tr> \
            <th class="header" \
        ng-class="{\'sortable\': column.sortable,\'sort-down\': column.sort==\'down\', \'sort-up\': column.sort==\'up\'}" \
        ng-click="sortBy(column)" \
        ng-repeat="column in columns"><div>{{column.title}}</div></th> \
        </tr> \
            <tr ng-show="filter.active"> \
            <th class="filter" ng-repeat="column in columns"> \
            <div ng-repeat="(name, filter) in column.filter">\
            <input type="text" ng-model="grid.filter[name]" class="input-filter" ng-show="filter == \'text\'" /> \
            <select class="filter filter-select" ng-options="data.id as data.title for data in column.data" ng-model="grid.filter[name]" ng-show="filter == \'select\'"></select> \
            <input type="text" date-range ng-model="grid.filter[name]" ng-show="filter == \'date\'" /> \
            <button class="btn btn-primary btn-block" ng-click="doFilter()" ng-show="filter == \'button\'">Filter</button> \
        </div>\
        </th> \
        </tr> \
        </thead>';
        var pager = '<div class="pagination">\
            <ul class="pagination ng-cloak" ng-show="pager && pager.count > 1"> \
            <li ng-class="{\'disabled\':pager.current == 1}"><a ng-click="goToPage(pager.current-1)" href="javascript:;">&laquo;</a></li> \
            <li ng-show="pager.current > 4"><a ng-click="goToPage(1)" href="javascript:;">1</a></li> \
            <li class="disabled" ng-show="pager.current > 4 && pager.count > 6"><span>...</span></li> \
            <li ng-repeat="page in pager.pages" ng-class="{\'disabled\':pager.current == page}"><a href="javascript:;" ng-click="goToPage(page)">{{page}}</a></li> \
            <li class="disabled" ng-show="pager.current + 3 < pager.count && pager.count > 6"><span>...</span></li> \
            <li ng-show="pager.current + 2 < pager.count && pager.count > 5"><span><a ng-click="goToPage(pager.count)" href="javascript:;">{{pager.count}}</a></span></li> \
            <li ng-class="{\'disabled\':pager.current == pager.count}"><a ng-click="goToPage(pager.current+1)" href="javascript:;">&raquo;</a></li> \
        </ul> \
            <div class="btn-group pull-right"> \
            <button type="button" ng-class="{\'active\':grid.count == 10}" ng-click="goToPage(pager.current, 10)" class="btn btn-mini">10</button> \
            <button type="button" ng-class="{\'active\':grid.count == 25}" ng-click="goToPage(pager.current, 25)" class="btn btn-mini">25</button> \
            <button type="button" ng-class="{\'active\':grid.count == 50}" ng-click="goToPage(pager.current, 50)" class="btn btn-mini">50</button> \
            <button type="button" ng-class="{\'active\':grid.count == 100}" ng-click="goToPage(pager.current, 100)" class="btn btn-mini">100</button> \
        </div>\
        </div>';
        return {
            restrict: 'A',
            priority: 1001,
            controller: function($scope, $timeout) {
                $scope.goToPage = function(page, count) {
                    var data = $scope.grid;
                    if (((page > 0 && data.page !== page && $scope.pager.count >= page) || angular.isDefined(count)) && $scope.callback) {
                        data.page = page;
                        data.count = count || data.count;
                        $scope.callback(data);
                    }
                };
                $scope.doFilter = function() {
                    $scope.grid.page = 1;
                    var data = $scope.grid;
                    if ($scope.callback) {
                        $scope.callback(data);
                    }
                };
                $scope.grid = {
                    page: 1,
                    count: 10,
                    filter: {},
                    sorting: [],
                    sortingDirection: []
                };
                $scope.sortBy = function(column) {
                    if (!column.sortable) {
                        return;
                    }
                    var sorting = $scope.grid.sorting.length && ($scope.grid.sorting[0] === column.sortable) && $scope.grid.sortingDirection[0];
                    $scope.grid.sorting = [column.sortable];
                    $scope.grid.sortingDirection = [!sorting];

                    angular.forEach($scope.columns, function(column) {
                        column.sort = false;
                    });
                    column.sort = sorting ? 'up' : 'down';

                    if ($scope.callback) {
                        $scope.callback($scope.grid);
                    }
                };
            },
            compile: function(element, attrs) {
                element.addClass('table');
                var i = 0;
                var columns = [];
                angular.forEach(element.find('td'), function(item) {
                    var el = $(item);
                    columns.push({
                        id: i++,
                        title: el.attr('title') || el.text(),
                        sortable: el.attr('sortable') ? el.attr('sortable') : false,
                        filter: el.attr('filter') ? $parse(el.attr('filter'))() : false,
                        filterData: el.attr('filter-data') ? el.attr('filter-data') : null
                    });
                });
                return function(scope, element, attrs) {
                    scope.callback = scope[attrs.ngTable];
                    scope.columns = columns;

                    var getInterval = function(page, numPages) {
                        var midRange = 5;
                        var neHalf, upperLimit, start, end;
                        neHalf = Math.ceil(midRange / 2);
                        upperLimit = numPages - midRange;
                        start = page > neHalf ? Math.max(Math.min(page - neHalf, upperLimit), 0) : 0;
                        end = page > neHalf ?
                            Math.min(page + neHalf - (midRange % 2 > 0 ? 1 : 0), numPages) :
                        Math.min(midRange, numPages);
                        return {start: start,end: end};
                    };

                    scope.$watch(attrs.pager, function(value) {
                        if (angular.isUndefined(value)) {
                            return;
                        }
                        var interval = getInterval(value.current, value.count);
                        value.pages = [];
                        for (var i = interval.start + 1; i < interval.end + 1; i++) {
                            value.pages.push(i);
                        }
                        scope.pager = value;
                        scope.grid.count = value.countPerPage;
                    });

                    angular.forEach(columns, function(column) {
                        if (!column.filterData) {
                            return;
                        }
                        var promise = scope[column.filterData](column);
                        delete column.filterData;
                        promise.then(function(data) {
                            if (!angular.isArray(data)) {
                                data = [];
                            }
                            data.unshift({ title: '-' });
                            column.data = data;
                        });
                    });
                    if (!element.hasClass('ng-table')) {
                        var html = $compile(template)(scope);
                        var pagination = $compile(pager)(scope);
                        element.filter('thead').remove();
                        element.prepend(html).addClass('ng-table');
                        element.after(pagination);
                    }
                };
            }
        };
    }).
    directive('appVersion', ['version', function(version) {
        return function(scope, elm, attrs) {
            elm.text(version);
        };
    }]);
