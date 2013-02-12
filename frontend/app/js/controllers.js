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

var ResultListCntl = ['$scope', function($scope) {
    $scope.results = [
        {
            token: 'IzUHfOw7agc24OGOKXL',
            last_modified: '2013-02-10T21:59:49+0000',
            status: 'pending'
        },
        {
            token: 'qTZcVl1gFFEhtgGfKTf',
            last_modified: '2013-02-10T21:59:49+0000',
            status: 'done'
        },
        {
            token: 'qTZcVl1gFFEhtgGfKTf',
            last_modified: '2013-02-10T21:59:49+0000',
            status: 'unknown'
        }
    ];
}];

function ResultDetailCntl() {
}