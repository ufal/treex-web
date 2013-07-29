'use strict';

angular.module('TreexWebApp').controller(
  'ResultDetailCtrl',
  ['$scope', '$routeParams', '$location', '$window', 'Result', 'Tour',
   function($scope, params, $location, $window, Result, Tour) {
     $scope.loading = true;

     if (Tour.isRunning()) {
       $scope.$watch('result.job.status', function(value) {
         if (value == 'queued' || value == 'working') {
           Tour.showStep(4);
         } else if (value) {
           Tour.end();
         }
       });
     }

     $scope.result = Result.get(params.resultId).then(function(result) {
       $scope.loading = false;

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

     $scope.rerun = angular.noop;
   }]);
