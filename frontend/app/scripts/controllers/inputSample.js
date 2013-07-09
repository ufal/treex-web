'use strict';

angular.module('TreexWebApp')
  .controller('InputSampleCtrl', ['$scope', 'Input', 'Treex', function ($scope, Input, Treex) {
    $scope.status = 'loading';
    $scope.error = null;

    $scope.samples = Input.sampleFiles().then(function(data) {
      $scope.status = data && data.length > 0 ? 'result' : 'empty';
      return data;
    }, function(reason) {
      $scope.status = 'error';
      $scope.error = reason.data.error;
    });

    $scope.insert = function(file) {
      Input.getSample(file).then(function(text) {
        $scope.query.input = text;
        $scope.dismiss();
      });
    };
  }]);
