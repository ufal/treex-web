'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioDetailCtrl',
  ['$scope', '$location', '$routeParams', 'Scenario', 'Treex', 'Result',
   function($scope, $location, params, Scenario, Treex, Result) {
     var scenario;
     $scope.status = 'loading';
     $scope.languagesMap = Treex.languagesMap();
     $scope.scenario = Scenario.get({id : params.scenarioId}, function(data) {
       $scope.status = 'scenario';
       scenario = data;
       return data;
     }, function() {
       $scope.status = 'not-found';
     });

     $scope.run = function() {
       if (!scenario) return;
       var result = Result.lastResult = new Result();
       result.scenario = scenario.scenario;
       result.name = scenario.name;
       result.input = result.sample = scenario.sample;
       $location.path('/run');
     };

     $scope.remove = function() {
       if (!scenario) return;
       scenario.$delete().then(function() {
         $location.path('/scenarios');
       });
     };
   }]);
