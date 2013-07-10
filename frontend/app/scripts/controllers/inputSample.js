'use strict';

angular.module('TreexWebApp')
  .controller('InputSampleCtrl', ['$scope', '$timeout', 'Input', 'Treex', function ($scope, $timeout, Input, Treex) {
    $scope.status = 'loading';
    $scope.error = null;

    $scope.$on('modal-shown', function() {
      if ($scope.samples) return;
      $scope.samples = Input.sampleFiles().then(function(data) {
        $scope.status = data && data.length > 0 ? 'result' : 'empty';
        $timeout(function() {
          $scope.$modal('layout');
        });
        return data;
      }, function(reason) {
        $scope.status = 'error';
        $scope.error = reason.data.error;
        $timeout(function() {
          $scope.$modal('layout');
        });
      });
      $scope.$apply();
    });

    $scope.insert = function(file) {
      Input.getSample(file).then(function(text) {
        $scope.query.input = text;
        $scope.dismiss();
      });
    };
  }]);
