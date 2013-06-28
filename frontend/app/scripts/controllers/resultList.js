'use strict';

angular.module('TreexWebApp')
  .controller('ResultListCtrl', ['$scope', 'Result', function($scope, Result) {
    $scope.status = 'loading';
    $scope.results = Result.query().then(function(results) {
      $scope.status = (results.length > 0) ? 'results' : 'empty';
      results.$remove = function(item) {
        var self = this;
        item.$delete().then(function() {
          var idx = self.indexOf(item);
          if (idx != -1) {
            self.splice(idx, 1);
          }
          if (self.length == 0) $scope.status = 'empty';
        });
      };
      return results;
    });

    $scope.trash = function(index) {
      $scope.results.$remove(index);
    };
  }]);
