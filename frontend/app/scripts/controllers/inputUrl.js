'use strict';

angular.module('TreexWebApp')
  .controller('InputUrlCtrl', ['$scope', '$timeout', 'Input',  function($scope, $timeout, Input) {
    $scope.extract = function() {
      $scope.loading = true;
      $scope.error = null;
      $scope.text = Input.loadUrl($scope.url).then(function(data) {
        $scope.loading = false;

        $timeout(function() {
          $scope.$modal('layout');
        });
        $scope.text = data;
        return data;
      }, function(reason) {
        $scope.loading = false;
        $scope.error = reason.data.error;
        $timeout(function() {
          $scope.$modal('layout');
        });
      });
    };

    $scope.insert = function() {
      $scope.query.input = $scope.text;
      $scope.dismiss();
    };
  }]);
