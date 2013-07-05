'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioPickCtrl',
  ['$scope', '$rootScope', '$timeout', 'Treex', 'Scenario',
   function($scope, $rootScope, $timeout, Treex, Scenario) {
     $scope.languages = Scenario.languages();
     $scope.languagesMap = Treex.languagesMap();

     function fetchScenarios(lang) {
       $scope.status = 'loading';
       $scope.scenarios = Scenario.query({language: lang}, function(data) {
         $scope.status = (data.length > 0) ? 'result' : 'empty';
       });
     }

     $scope.$watch('visible', function(visible) {
       if (visible) fetchScenarios($scope.language);
       else $scope.status = 'loading';
     });

     $scope.$watch('language', function(value, old) {
       if (value !== old && $scope.visible) {
         fetchScenarios(value);
       }
     });

     // propagate scenario pick to the parent scope
     $scope.pick = function(scenario) {
       $timeout(function() {
         var q = $scope.query;
         q.scenario = scenario;
         if (scenario.sample && !q.input) q.input = scenario.sample;
         q.scenario = scenario;
         q.scenario.compose = true;
         $scope.dismiss();
       });
     };
   }]);
