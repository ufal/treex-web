'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioDetailCtrl',
  ['$scope', '$routeParams', 'Scenario', 'Treex',
   function($scope, params, Scenario, Treex) {
     $scope.status = 'loading';
     $scope.languagesMap = Treex.languagesMap();
     $scope.scenario = Scenario.get({id : params.scenarioId}, function(data) {
       $scope.status = 'scenario';
       return data;
     }, function() {
       $scope.status = 'not-found';
     });
   }]);
