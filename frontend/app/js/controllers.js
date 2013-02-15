'use strict';

/* Controllers */

var AuthCntl = ['$scope', function($scope) {
    $scope.loggedIn = false;

    $scope.$on('auth:loggedIn', function(){
        $scope.loggedIn = true;
    });

    $scope.$on('auth:loggedOut', function(){
        $scope.loggedIn = false;
    });
}];

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

var ScenarioPickCntl = ['$scope', '$rootScope', 'Treex', function($scope, $rootScope, Treex) {
        $scope.languages = Treex.languages();
        ScenarioWatch($scope, $rootScope, this);
    }],
    RunTreexCntl = ['$scope', '$rootScope', 'Treex', function($scope, $rootScope, Treex) {
        $scope.languages = Treex.languages();
        ScenarioWatch($scope, $rootScope, this);
    }],
    ResultListCntl = ['$scope', 'Results', function($scope, Results) {
        $scope.status = 'loading';
        $scope.results = Results.query().then(function(results) {
            $scope.status = (results.length > 0) ? 'results' : 'empty';
            return results;
        });
    }],
    ResultDetailCntl = ['$scope', '$routeParams', 'Result', function($scope, params, Result) {
        $scope.loading = true;
        $scope.result = Result.get(params.resultId).then(function(result) {
            $scope.loading = false;
            return result;
        });
    }];
