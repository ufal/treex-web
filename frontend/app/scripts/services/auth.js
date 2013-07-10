'use strict';

angular.module('TreexWebApp')
  .factory('Auth', ['$rootScope', '$http', 'apiUrl', function(scope, $http, api) {
    var loggedIn = false;
    var user = null;
    var redirectPath = '/';

    function Auth() {}
    Auth.ping = function() {
      return $http.get(api + 'auth').success(function(data) {
        scope.$broadcast('auth:logginConfirmed');
        loggedIn = true;
        user = data;
      }).error(function() {
        loggedIn = false;
        user = null;
      });
    };

    Auth.redirectAfterLogin = function(path) {
      if (path == null)
        return redirectPath;
      redirectPath = path || '/';
    };

    Auth.loggedIn = function() { return loggedIn; };

    Auth.user = function() {
      return user;
    };

    Auth.login = function(params) {
      return $http.post(api + 'auth', params).success(function(data) {
        scope.$broadcast('auth:logginConfirmed');
        loggedIn = true;
        user = data;
      });
    };

    Auth.logout = function() {
      return $http.delete(api + 'auth').success(function(data) {
        scope.$broadcast('auth:loggedOut');
        loggedIn = false;
        user = null;
        return data;
      });
    };

    return Auth;
  }]);