'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioPickCtrl',
  ['$scope', '$rootScope', '$timeout', 'Treex', 'Scenario', 'Tour',
   function($scope, $rootScope, $timeout, Treex, Scenario, Tour) {
     $scope.status = 'loading';
     $scope.languages = Scenario.languages();
     $scope.languagesMap = Treex.languagesMap();

     function fetchScenarios(lang) {
       $scope.status = 'loading';
       $scope.scenarios = Scenario.query({language: lang}, function(data) {
         $scope.status = (data.length > 0) ? 'result' : 'empty';
         return data;
       });
     }

     $scope.$on('modal-shown', function() {
       fetchScenarios($scope.language);
       $scope.$apply();
     });

     $scope.$watch('language', function(value, old) {
       if (value !== old) {
         fetchScenarios(value);
       }
     });

     // propagate scenario pick to the parent scope
     $scope.pick = function(scenario) {
       $timeout(function() {
         var q = $scope.query;
         q.scenarioId = scenario.id;
         q.scenario = scenario.scenario;
         q.name = scenario.name;
         q.description = scenario.description;
         q.sample = scenario.sample;
         if (scenario.sample && !q.input && !q.filename) q.input = scenario.sample;
         q.compose = true;
         $scope.dismiss();
       });
     };
   }]);
