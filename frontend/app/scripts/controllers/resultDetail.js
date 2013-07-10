'use strict';

angular.module('TreexWebApp').controller(
  'ResultDetailCtrl',
  ['$scope', '$routeParams', '$location', '$window', 'Result',
   function($scope, params, $location, $window, Result) {
     $scope.loading = true;
     $scope.result = Result.get(params.resultId).then(function(result) {
       $scope.loading = false;

       $scope.download = function() {
         $window.open(result.downloadUrl);
       };

       $scope.rerun = function() {
         var wait = 2;
         result.$input().then(function(data) {
           result.input = data;
           --wait || done();
         });
         result.$scenario().then(function(data) {
           result.scenario = data;
           --wait || done();
         });

         function done() {
           Result.lastResult = result;
           $location.path('/run');
         }
       };

       return result;
     });

     $scope.download = angular.noop;
     $scope.rerun = angular.noop;
   }]);
