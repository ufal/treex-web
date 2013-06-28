'use strict';

angular.module('TreexWebApp')
  .factory('Scenario', ['$resource', 'apiUrl', function($resource, api) {
    var Scenario = $resource(api + 'scenarios/:id', { id : '@id' },
                             { 'update': {method : 'PUT' },
                               'query': {method: 'GET', params: { language: '@language' }, isArray : true}
                             });
    return Scenario;
  }]);
