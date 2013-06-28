'use strict';

angular.module('TreexWebApp')
  .factory('Auth', ['$rootScope', '$http', 'apiUrl', function(scope, $http, api) {
    var loggedIn = false;
    var user = {};
    var redirectPath = '/';

    function Auth() {}
    Auth.ping = function() {
      return $http.get(api + 'auth').success(function() {
        scope.$broadcast('auth:logginConfirmed');
        loggedIn = true;
      });
    };

    Auth.redirectAfterLogin = function(path) {
      if (path == null)
        return redirectPath;
      redirectPath = path || '/';
    };

    Auth.loggedIn = function() { return loggedIn; };

    Auth.login = function(params) {
      return $http.post(api + 'auth', params).success(function(data) {
        scope.$broadcast('auth:logginConfirmed');
        loggedIn = true;
        user = data;
        return data;
      });
    };

    Auth.logout = function() {
      return $http.delete(api + 'auth').success(function(data) {
        scope.$broadcast('auth:loggedOut');
        loggedIn = false;
        user = {};
        return data;
      });
    };

    return Auth;
  }]);