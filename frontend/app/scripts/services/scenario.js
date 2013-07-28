'use strict';

angular.module('TreexWebApp')
  .factory('Scenario', ['$resource', '$http', 'Auth', 'apiUrl', function($resource, $http, Auth, api) {
    var Scenario = $resource(api + 'scenarios/:id', { id : '@id' },
                             { 'update': {method : 'PUT' },
                               'query': {method: 'GET', params: {language: '@language'}, isArray : true}
                             }),
        proto = Scenario.prototype,
        template =
          "Util::SetGlobal language=und    # desired language e.g. en,cs,de...\n" +
          "Read::Text                      # 'from' parameter will be ignored\n" +
          "\n# Your scenario goes here...\n\n" +
          "Write::Treex                    # 'to' parameter will be ignored\n";

    proto.downloadUrl = function() {
      return api + 'scenarios/' + this.id + '/download';
    };
    proto.isEditable = function() {
      return Scenario.isEditable(this);
    };

    Scenario.$template = template;

    Scenario.isEditable = function(scenario) {
      var user = Auth.user();
      return (user && scenario.user && user.id && user.id == scenario.user.id);
    };

    Scenario.languages = function() {
      return $http.get(api + 'scenarios/languages').then(function(responce) {
        return responce.data;
      });
    };
    return Scenario;
  }]);
