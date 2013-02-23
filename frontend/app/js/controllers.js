'use strict';

/* Controllers */


function HomePageCntl() {
}

function ScenarioWatch(scope, rootScope, cntl) {
    cntl.broadcast = false;
    scope.$watch('language', function(value) {
        cntl.broadcast = true;
        rootScope.$broadcast('scenario:language', value);
        cntl.broadcast = false;
    });

    scope.$on('scenario:language', function(event, language) {
        if (cntl.broadcast) return;
        scope.language = language;
    });
}

var AuthCntl = ['$scope', function($scope) {
    $scope.loggedIn = false;

    $scope.$on('auth:loggedIn', function(){
        $scope.loggedIn = true;
    });

    $scope.$on('auth:loggedOut', function(){
        $scope.loggedIn = false;
    });
}],
    LoginCntl = [ function() { }],
    SignUpCntl = [ function() { }],
    InputUrlCntl = ['$scope', 'Input', function($scope, Input) {
        $scope.extract = function() {
            $scope.loading = true;
            $scope.error = null;
            $scope.text = Input.loadUrl($scope.url).then(function(data) {
                $scope.loading = false;
                return data;
            }, function(reason) {
                $scope.loading = false;
                $scope.error = reason.data.error;
            });
        };

        $scope.insert = function() {
            if ($scope.$parent) {
                $scope.$parent.input = $scope.text;
            }
            $scope.dismiss();
        };
    }],
    ScenarioPickCntl = ['$scope', '$rootScope', '$timeout', 'Treex', 'Scenarios', function($scope, $rootScope, $timeout, Treex, Scenarios) {
        $scope.languages = Treex.languages();
        ScenarioWatch($scope, $rootScope, this);

        function fetchScenarios(lang) {
            $scope.status = 'loading';
            $scope.scenarios = Scenarios.query(lang).then(function(data) {
                $scope.status = (data.length > 0) ? 'result' : 'empty';
                return data;
            });
        }

        $scope.$watch('visible', function(visible) {
            if (visible) fetchScenarios($scope.language);
            else $scope.status = 'loading';
        });

        $scope.$watch('language', function(value, old) {
            if (value !== old && $scope.visible) {
                fetchScenarios(value);
            }
        });

        // propagete scenario pick to the parent scope
        $scope.pick = function(scenario) {
            $timeout(function() {
                if ($scope.$parent !== null) {
                    $scope.$parent.scenario = scenario;
                }
                $scope.dismiss();
            });
        };
    }],
    RunTreexCntl =
        ['$scope', '$rootScope', '$location', '$anchorScroll', '$timeout', 'Treex',
         function($scope, $rootScope, $location, $anchorScroll, $timeout, Treex) {
             $scope.languages = Treex.languages();
             $scope.scenario = { compose: false };
             ScenarioWatch($scope, $rootScope, this);
             $scope.$watch('scenario.compose', function(value) {
                 if (value && $scope.ace) {
                     $timeout(function() {
                         $scope.ace.resize();
                         $scope.ace.focus();
                     });
                 }
             });

             $scope.submit = function() {
                 if ($scope.form.$invalid) return;
                 Treex.query({
                     language: $scope.language.value,
                     scenario: $scope.scenario.scenario,
                     scenario_id: $scope.scenario.id,
                     scenario_name: $scope.scenario.name,
                     input: $scope.input
                 }).then(function(result) {
                     $location.path('/result/'+result.token);
                 }, function(reason) {
                     $scope.error = angular.isObject(reason.data) ?
                         reason.data.error : reason.data;
                     $anchorScroll('query-error');
                 });
             };
    }],
    ScenariosCntl = ['$scope', 'Scenarios', function($scope, Scenarios) {
        $scope.status = 'loading';
        $scope.scenarios = Scenarios.query().then(function(scenarios) {
            $scope.status = (scenarios.length > 0) ? 'results' : 'empty';
            return scenarios;
        });
    }],
    ScenarioFormCntl = ['$scope', 'Scenario', 'Treex', function($scope, Scenario, Treex) {
        $scope.languages = Treex.languages();
        // TODO: save methods and other stuff
    }],
    ResultListCntl = ['$scope', 'Results', function($scope, Results) {
        $scope.status = 'loading';
        $scope.results = Results.query().then(function(results) {
            $scope.status = (results.length > 0) ? 'results' : 'empty';
            results.$remove = function(item) {
                var self = this;
                item.$delete().then(function() {
                    var idx = self.indexOf(item);
                    if (idx != -1) {
                        self.splice(idx, 1);
                    }
                    if (self.length == 0) $scope.status = 'empty';
                });
            };
            return results;
        });

        $scope.trash = function(index) {
            $scope.results.$remove(index);
        };
    }],
    ResultDetailCntl = ['$scope', '$routeParams', 'Result', function($scope, params, Result) {
        $scope.loading = true;
        $scope.result = Result.get(params.resultId).then(function(result) {
            $scope.loading = false;
            return result;
        });
    }];
