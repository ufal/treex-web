'use strict';

angular.module('TreexWebApp')
  .factory('Scenario', ['$resource', '$http', 'apiUrl', function($resource, $http, api) {
    var Scenario = $resource(api + 'scenarios/:id', { id : '@id' },
                             { 'update': {method : 'PUT' },
                               'query': {method: 'GET', params: {language: '@language'}, isArray : true}
                             });


    var proto = Scenario.prototype;
    proto.downloadUrl = function() {
      return api + 'scenarios/' + this.id + '/download';
    };
    Scenario.languages = function() {
      return $http.get(api + 'scenarios/languages').then(function(responce) {
        return responce.data;
      });
    };
    return Scenario;
  }]);
