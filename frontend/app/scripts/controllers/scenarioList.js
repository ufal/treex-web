'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioListCtrl',
  ['$scope', '$filter', 'Scenario', 'Treex',
   function($scope, $filter, Scenario, Treex) {
     $scope.languagesMap = Treex.languagesMap();
     $scope.status = 'loading';
     $scope.update = function(params) {
       Scenario.query({ language : '' }, function(scenarios) {
         if (scenarios.length == 0) {
           $scope.status = 'empty';
           $scope.totalFound = 0;
           return [];
         }
         var maxPages = Math.ceil(scenarios.length / params.count),
             pager = {};

         $scope.status = 'results';
         $scope.pager = pager = {
           current : params.page > maxPages ? maxPages : params.page,
           count : maxPages,
           countPerPage : params.count
         };
         if (params.sorting && params.sorting[0]) {
           scenarios = $filter('orderBy')(scenarios, params.sorting[0], params.sortingDirection[0]);
         }
         $scope.scenarios = scenarios.slice((pager.current-1)*pager.countPerPage, pager.current*pager.countPerPage);
       });
     };

     $scope.pager = {
       current: 1,
       count: 1,
       countPerPage: 10
     };

     $scope.update({
       page: 1,
       count: 10
     });
   }]);
