/*global angular */
'use strict';

var web = angular.module('treex-web', ['$strap.directives', 'treex-directives', 'treex-filters', 'treex-services']);
web.config(['$routeProvider', '$locationProvider', '$httpProvider', function($routeProvider, $locationProvider, $httpProvider) {
    $routeProvider.
        when('/', { templateUrl: 'partials/home.html', controller: HomePageCntl }).
        when('/run', { templateUrl: 'partials/treex/run.html', controller: RunTreexCntl }).
        when('/results', { templateUrl: 'partials/result/list.html', controller: ResultListCntl }).
        when('/result/:resultId', { templateUrl: 'partials/result/detail.html', controller: ResultDetailCntl });
    $locationProvider.html5Mode(true);

    // Use x-www-form-urlencoded Content-Type
    $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8';

    // Override $http service's default transformRequest
    $httpProvider.defaults.transformRequest = [function(data) {
        return angular.isObject(data) && String(data) !== '[object File]' ? jQuery.param(data) : data;
    }];
}]);
