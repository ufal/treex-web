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
    $scope.results = Results.query();
}];

function ResultDetailCntl() {
}