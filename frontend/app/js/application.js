/*global angular */
'use strict';

var web = angular.module('treex-web', ['$strap.directives', 'http-auth-interceptor', 'treex-directives', 'treex-filters', 'treex-services']);
web.config(['$routeProvider', '$locationProvider', '$httpProvider', function($routeProvider, $locationProvider, $httpProvider) {
    $routeProvider.
        when('/', { templateUrl: 'partials/home.html', controller: HomePageCntl }).
        when('/login', { templateUrl: 'partials/auth/login.html', controller: LoginCntl }).
        when('/logout', { templateUrl: 'partials/auth/logout.html', controller: LogoutCntl }).
        when('/signup', { templateUrl: 'partials/auth/signup.html', controller: SignUpCntl }).
        when('/signup/success', { templateUrl: 'partials/auth/signup-success.html', controller: SignUpCntl }).
        when('/run', { templateUrl: 'partials/treex/run.html', controller: RunTreexCntl }).
        when('/scenarios', { templateUrl: 'partials/scenario/list.html', controller: ScenariosCntl }).
        when('/scenario', { login: true, templateUrl: 'partials/scenario/form.html', controller: ScenarioFormCntl }).
        when('/results', { templateUrl: 'partials/result/list.html', controller: ResultListCntl }).
        when('/result/:resultId', { templateUrl: 'partials/result/detail.html', controller: ResultDetailCntl });
    $locationProvider.html5Mode(true);

    // TODO: This have to be removed in future
    // Use x-www-form-urlencoded Content-Type
    $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8';

    // Override $http service's default transformRequest
    $httpProvider.defaults.transformRequest = [function(data) {
        return angular.isObject(data) && String(data) !== '[object File]' ? jQuery.param(data) : data;
    }];
}]);

web.run(['$rootScope', '$route', '$location', 'Auth', function(scope, $route, $location, Auth) {
    Auth.ping();

    var loginPath = '/login';
    // register listener to watch route changes
    scope.$on( '$routeChangeStart', function(event, next, current) {
        var path = $location.path();
        if (next.$route.login === true) {
            if (Auth.loggedIn() !== true) {
                Auth.redirectAfterLogin(path); // save redirect path
                if (next.redirectTo != loginPath) {
                    next.prevRedirectTo = next.redirectTo;
                    next.redirectTo = loginPath;
                }
            } else {
                if (next.redirectTo == loginPath) {
                    next.redirectTo = next.prevRedirectTo;
                }
            }
        } else if (path != loginPath) {
            Auth.redirectAfterLogin('/'); // reset redirect path
        }
    });
}]);
