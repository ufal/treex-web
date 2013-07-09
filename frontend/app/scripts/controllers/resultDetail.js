'use strict';

angular.module('TreexWebApp').controller(
  'ResultDetailCtrl',
  ['$scope', '$routeParams', '$window', 'Result',
   function($scope, params, $window, Result) {
     $scope.loading = true;
     $scope.result = Result.get(params.resultId).then(function(result) {
       $scope.loading = false;

       $scope.download = function() {
         $window.open(result.downloadUrl);
       };

       return result;
     });

     $scope.download = angular.noop;
   }]);
