'use strict';

angular.module('TreexWebApp').controller(
  'RunTreexCtrl',
  ['$scope', '$location', '$anchorScroll', '$timeout', 'Treex', 'Result', 'Tour',
   function($scope, $location, $anchorScroll, $timeout, Treex, Result, Tour) {

     if (Tour.isRunning()) {
       Tour.showStep(1);
       Result.lastResult = null;
     }

     $scope.query = Result.lastResult || (Result.lastResult = new Result());

     $scope.$watch('query.compose', function(value) {
       if (value && $scope.ace) {
         $timeout(function() {
           $scope.ace.resize(true);
           $scope.ace.focus();
         });
       }
     });

     if ($scope.query.scenario) {
       $scope.query.compose = true;
     }

     $scope.submit = function() {
       if ($scope.form.$invalid) return;
       var q = $scope.query;
       Treex.query({
         scenario: q.scenario,
         scenario_name: q.name,
         input: q.input
       }).then(function(result) {
         Result.lastResult = null;
         $location.path('/result/'+result.token);
       }, function(reason) {
         $scope.error = angular.isObject(reason.data) ?
           reason.data.error : reason.data;
         $anchorScroll('query-error');
       });
     };
   }]);
