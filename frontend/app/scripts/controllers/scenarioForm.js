'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioFormCtrl',
  ['$scope', '$routeParams', '$location', 'Scenario', 'Treex',
   function($scope, params, $location, Scenario, Treex) {
     $scope.languages = Treex.languages();
     $scope.status = 'form';

     var scenario;
     if (params.scenarioId) {
       $scope.status = 'loading';
       $scope.scenario = Scenario.get({id : params.scenarioId}, function(data) {
         $scope.status = 'form';
         scenario = data;
         return data;
       }, function() {
         $scope.status = 'not-found';
       });
     } else {
       scenario = $scope.scenario = new Scenario({ 'public' : false, 'scenario': Scenario.$template });
     }

     $scope.saveOrUpdate = function(redirect) {
       if (scenario.id) {
         scenario.$update(function() { postSave(redirect); });
       } else {
         scenario.$save(function() { postSave(redirect); });
       }
     };

     function postSave(redirect) {
       $scope.form.$setPristine();
       if (redirect) {
         $location.path('/scenarios');
       }
     }
   }]);
