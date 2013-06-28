'use strict';

angular.module('TreexWebApp').controller(
  'ResultDetailCtrl',
  ['$scope', '$routeParams', 'Result',
   function($scope, params, Result) {
     $scope.loading = true;
     $scope.result = Result.get(params.resultId).then(function(result) {
       $scope.loading = false;
       return result;
     });
   }]);
