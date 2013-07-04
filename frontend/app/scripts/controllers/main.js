'use strict';

angular.module('TreexWebApp')
  .controller('MainCtrl', ['$scope', 'Tour', function ($scope, Tour) {

    if (Tour.isRunning()) {
      Tour.showStep(0);
    }

    $scope.startTour = function() {
      Tour.start();
    };
  }]);
