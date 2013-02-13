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

var ResultListCntl = ['$scope', 'Results', function($scope, Results) {
    $scope.status = 'loading';
    $scope.results = Results.query().then(function(results) {
        $scope.status = (results.length > 0) ? 'results' : 'empty';
        return results;
    });
}];

var ResultDetailCntl = ['$scope', 'Result', function($scope, Result) {
    console.log($scope);
}];
