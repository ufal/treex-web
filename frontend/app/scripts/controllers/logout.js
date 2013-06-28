'use strict';

angular.module('TreexWebApp')
  .controller('LogoutCtrl', [ '$location', 'Auth', function($location, Auth) {
    Auth.logout().then(function() {
      $location.path('/');
    });
  }]);
