'use strict';

angular.module('TreexWebApp')
  .factory('User', [ '$http', 'apiUrl', function($http, api) {
    function User(data) {
      angular.copy(data || {}, this);
    }

    User.emailAvailable = function(email) {
      // TODO: validate email first
      var promise = $http.get(api + 'users/email-available', { 'params' : { 'email' : email} });
      return promise.then(function(responce) {
        return responce.data.available == 1;
      });
    };

    User.signup = function(data) {
      var promise = $http.post(api + 'users', data);
      return promise.then(function(responce) {
        return new User(responce.data);
      });
    };

    return User;
  }]);
