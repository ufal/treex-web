'use strict';

angular.module('TreexWebApp')
  .controller('SignUpCtrl', [ '$scope', '$location', '$anchorScroll', 'User', function($scope, $location, $anchorScroll, User) {
    $scope.signup = function() {
      User.signup($scope.user).then(function(user) {
        $location.path('/signup/success');
      }, function(reason) {
        $scope.error = angular.isObject(reason.data) ?
          reason.data.error : reason.data;
        $anchorScroll('form-error');
      });
    };
  }]);
