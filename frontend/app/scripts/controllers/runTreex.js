'use strict';

angular.module('TreexWebApp').controller(
  'RunTreexCtrl',
  ['$scope', '$rootScope', '$location', '$anchorScroll', '$timeout', 'Treex', 'Tour',
   function($scope, $rootScope, $location, $anchorScroll, $timeout, Treex, Tour) {

     if (Tour.isRunning()) {
       Tour.showStep(1);
     }

     $scope.languages = Treex.languages();
     $scope.scenario = { compose: false };
     Treex.watchLanguage($scope, this);
     $scope.$watch('scenario.compose', function(value) {
       if (value && $scope.ace) {
         $timeout(function() {
           $scope.ace.resize(true);
           $scope.ace.focus();
         });
       }
     });

     $scope.submit = function() {
       if ($scope.form.$invalid) return;
       Treex.query({
         language: $scope.language,
         scenario: $scope.scenario.scenario,
         scenario_id: $scope.scenario.id,
         scenario_name: $scope.scenario.name,
         input: $scope.input
       }).then(function(result) {
         $location.path('/result/'+result.token);
       }, function(reason) {
         $scope.error = angular.isObject(reason.data) ?
           reason.data.error : reason.data;
         $anchorScroll('query-error');
       });
     };
   }]);
