'use strict';

angular.module('TreexWebApp').controller(
  'RunTreexCtrl',
  ['$scope', '$rootScope', '$location', '$anchorScroll', '$timeout', 'Treex', 'Tour',
   function($scope, $rootScope, $location, $anchorScroll, $timeout, Treex, Tour) {

     if (Tour.isRunning()) {
       Tour.showStep(1);
     }

     $scope.query = {
       scenario : {compose: false}
     };
     Treex.watchLanguage($scope, this);
     $scope.$watch('query.scenario.compose', function(value) {
       if (value && $scope.ace) {
         $timeout(function() {
           $scope.ace.resize(true);
           $scope.ace.focus();
         });
       }
     });

     $scope.submit = function() {
       if ($scope.form.$invalid) return;
       var q = $scope.query;
       Treex.query({
         scenario: q.scenario.scenario,
         scenario_id: q.scenario.id,
         scenario_name: q.scenario.name,
         input: q.input
       }).then(function(result) {
         $location.path('/result/'+result.token);
       }, function(reason) {
         $scope.error = angular.isObject(reason.data) ?
           reason.data.error : reason.data;
         $anchorScroll('query-error');
       });
     };
   }]);
