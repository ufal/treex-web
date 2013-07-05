'use strict';

angular.module('TreexWebApp')
  .controller('InputUrlCtrl', ['$scope', 'Input', function($scope, Input) {
    $scope.extract = function() {
      $scope.loading = true;
      $scope.error = null;
      $scope.text = Input.loadUrl($scope.url).then(function(data) {
        $scope.loading = false;
        return data;
      }, function(reason) {
        $scope.loading = false;
        $scope.error = reason.data.error;
      });
    };

    $scope.insert = function() {
      $scope.query.input = $scope.text;
      $scope.dismiss();
    };
  }]);
