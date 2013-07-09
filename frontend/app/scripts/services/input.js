'use strict';

angular.module('TreexWebApp')
  .factory('Input', ['$http', 'apiUrl', function($http, api) {
    return {
      loadUrl: function(url) {
        return $http.post(api + 'input/url', { 'url': url }).then(function(responce) {
          return responce.data.content;
        });
      },
      sampleFiles: function() {
        return $http.get(api + 'input/samples').then(function(responce) {
          return responce.data;
        });
      },
      getSample: function(file) {
        return $http.get(api + 'input/samples/'+file).then(function(responce) {
          return responce.data.content;
        });
      }
    };
  }]);
