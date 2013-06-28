'use strict';

angular.module('TreexWebApp')
  .controller('AuthCtrl', ['$scope', function($scope) {
    $scope.loggedIn = false;

    $scope.$on('auth:logginConfirmed', function(){
      $scope.loggedIn = true;
    });

    $scope.$on('auth:loggedOut', function(){
      $scope.loggedIn = false;
    });
  }]);
