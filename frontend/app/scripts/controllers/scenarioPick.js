'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioPickCtrl',
  ['$scope', '$rootScope', '$timeout', 'Treex', 'Scenario',
   function($scope, $rootScope, $timeout, Treex, Scenario) {
     $scope.languages = Treex.languages();
     $scope.languagesMap = Treex.languagesMap();
     Treex.watchLanguage($scope, this);

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

     // propagete scenario pick to the parent scope
     $scope.pick = function(scenario) {
       $timeout(function() {
         if ($scope.$parent !== null) {
           $scope.$parent.scenario = scenario;
         }
         $scope.dismiss();
       });
     };
   }]);
