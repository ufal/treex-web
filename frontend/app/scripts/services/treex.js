'use strict';

angular.module('TreexWebApp').factory(
  'Treex',
  ['$http', '$q', '$rootScope', 'apiUrl', 'Result',
   function($http, $q, $rootScope, api, Result) {
     var languages, map;

     return {
       watchLanguage : function(scope, ctrl) {
         ctrl.broadcast = false;
         scope.$watch('language', function(value) {
           ctrl.broadcast = true;
           $rootScope.$broadcast('scenario:language', value);
           ctrl.broadcast = false;
         });

         scope.$on('scenario:language', function(event, language) {
           if (ctrl.broadcast) return;
           scope.language = language;
         });
       },
       query : function(data) {
         var promise = $http.post(api + 'query', data);
         return promise.then(function(responce) {
           return new Result(responce.data);
         });
       },
       languages : function() {
         if (languages) return languages;
         return languages = $http.get(api + 'treex/languages')
           .then(function(responce) {
             return responce.data;
           });
       },
       languagesMap : function() {
         if (map) return map;
         return map = this.languages().then(function(languages) {
           var index = {};
           angular.forEach(languages, function(group) {
             angular.forEach(group.options, function(lang) {
               index[lang.value] = lang.label;
             });
           });
           return index;
         });
       }
     };
   }]);
