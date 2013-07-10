'use strict';

angular.module('TreexWebApp')
  .controller('AuthCtrl', ['$scope', '$location', 'Auth', function($scope, $location, Auth) {

    Auth.ping().success(function(data) {
      if (!data.id) return;
      var redirect = Auth.redirectAfterLogin();
      if (redirect != '/')
        $location.path(redirect);
    });

    $scope.loggedIn = false;

    $scope.$on('auth:logginConfirmed', function(){
      $scope.loggedIn = true;
    });

    $scope.$on('auth:loggedOut', function(){
      $scope.loggedIn = false;
    });
  }]);
