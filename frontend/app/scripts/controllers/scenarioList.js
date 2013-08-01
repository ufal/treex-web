'use strict';

angular.module('TreexWebApp').controller(
  'ScenarioListCtrl',
  ['$scope', '$filter', '$location', '$window', 'Scenario', 'Result', 'Treex',
   function($scope, $filter, $location, $window, Scenario, Result, Treex) {
     $scope.languages = Scenario.languages();
     $scope.languagesMap = Treex.languagesMap();
     $scope.status = 'loading';

     $scope.$watch('language', function(value) {
       if (lastParams) {
         lastParams.page = 1;
         lastParams.filter || (lastParams.filter = {});
         lastParams.filter['languages'] = value;
         $scope.update(lastParams);
       }
     });

     var scenarios = [],
         lastParams;

     function fetchScenarios() {
       $scope.status = 'loading';
       $scope.languages = Scenario.languages();
       Scenario.query({ language : '' }, function(data) {
         if (data.length == 0) {
           $scope.status = 'empty';
           $scope.totalFound = 0;
           return [];
         }
         scenarios = data;
         for (var i = 0, ii = scenarios.length; i < ii; i++) {
           scenarios[i].editable = scenarios[i].isEditable();
         }

         $scope.update({
           page: 1,
           count: 10
         });
       });
     }

     $scope.$on('auth:loginConfirmed', function(){
       $scope.status = 'loading';
       fetchScenarios();
     });


     $scope.update = function(params) {
       var maxPages = Math.ceil(scenarios.length / params.count),
           pager = {},
           source = scenarios;

       lastParams = params;
       $scope.status = 'results';
       $scope.pager = pager = {
         current : params.page > maxPages ? maxPages : params.page,
         count : maxPages,
         countPerPage : params.count
       };
       if (params.filter && params.filter.languages) {
         var lang = parseInt(params.filter.languages);
         source = $filter('filter')(source, function(value) {
           return value.languages.indexOf(lang) != -1;
         });
       }
       if (params.sorting && params.sorting[0]) {
         source = $filter('orderBy')(source, params.sorting[0], params.sortingDirection[0]);
       }
       $scope.scenarios = source.slice((pager.current-1)*pager.countPerPage, pager.current*pager.countPerPage);
       $scope.scenarios.$remove = function(item) {
         var self = this;
         item.$delete().then(function() {
           var idx = self.indexOf(item);
           if (idx != -1) {
             self.splice(idx, 1);
           }
           if (self.length == 0) $scope.status = 'empty';
         });
       };
     };

     $scope.run = function(scenario) {
       var result = Result.lastResult = new Result();
       result.scenario = scenario.scenario;
       result.name = scenario.name;
       result.input = result.sample = scenario.sample;
       $location.path('/run');
     };

     $scope.download = function(scenario) {
       $window.open(scenario.downloadUrl());
     };

     $scope.pager = {
       current: 1,
       count: 1,
       countPerPage: 10
     };

     fetchScenarios();
   }]);
