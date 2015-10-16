'use strict';

angular.module('TreexWebApp', ['$strap.directives', 'http-auth-interceptor', 'blueimp.fileupload', 'ngResource', 'ngRoute', 'lindat'])
  .config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider.
      when('/', { templateUrl: 'views/home.html', controller: 'MainCtrl' }).
      //when('/login', { templateUrl: 'views/auth/login.html', controller: 'LoginCtrl' }).
      when('/logout', { templateUrl: 'views/auth/logout.html', controller: 'LogoutCtrl' }).
      //when('/signup', { templateUrl: 'views/auth/signup.html', controller: 'SignUpCtrl' }).
      //when('/signup/success', { templateUrl: 'views/auth/signup-success.html', controller: 'SignUpCtrl' }).
      when('/run', { templateUrl: 'views/treex/run.html', controller: 'RunTreexCtrl' }).
      when('/scenarios', { templateUrl: 'views/scenario/list.html', controller: 'ScenarioListCtrl' }).
      when('/scenario', { login: true, templateUrl: 'views/scenario/form.html', controller: 'ScenarioFormCtrl' }).
      when('/scenario/:scenarioId', { templateUrl: 'views/scenario/detail.html', controller: 'ScenarioDetailCtrl' }).
      when('/scenario/:scenarioId/edit', { login: true, templateUrl: 'views/scenario/form.html', controller: 'ScenarioFormCtrl' }).
      when('/results', { templateUrl: 'views/result/list.html', controller: 'ResultListCtrl' }).
      when('/result/:resultId', { templateUrl: 'views/result/detail.html', controller: 'ResultDetailCtrl' }).
      otherwise({ templateUrl: 'views/404.html' });

    $locationProvider.html5Mode(true);
  }])
  .run(['$rootScope', 'Piwik', '$location', function(scope, Piwik, $location) {

    // register listener to watch route changes
    scope.$on( '$routeChangeStart', function(event, next) {
      if (next && next.login === true) {
        scope.$broadcast('auth:loginRequired');
      }

      Piwik.setCustomUrl($location.absUrl());
      Piwik.trackPageView();
    });
  }]);
