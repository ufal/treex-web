'use strict';

angular.module('TreexWebApp')
  .controller('LoginCtrl', [ '$scope', '$location', 'Auth', function($scope, $location, Auth) {
    $scope.login = function() {
      Auth.login($scope.auth)
        .success(function() {
          $location.path(Auth.redirectAfterLogin());
        })
        .error(function(data) {
          $scope.error = data.error;
        });
    };
  }]);
