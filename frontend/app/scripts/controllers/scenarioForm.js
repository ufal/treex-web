'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioFormCtrl',
  ['$scope', '$routeParams', '$location', 'Scenario', 'Treex',
   function($scope, params, $location, Scenario, Treex) {
     $scope.languages = Treex.languages();
     var scenario = $scope.scenario =
           params.scenarioId ? Scenario.get({id : params.scenarioId}) : new Scenario();
     scenario['public'] = !!scenario['public'];
     $scope.saveOrUpdate = function() {
       if (scenario.id) {
         scenario.$update();
       } else {
         scenario.$save();
       }
     };
   }]);
