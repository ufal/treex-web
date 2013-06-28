'use strict';

angular.module('TreexWebApp')
  .factory('Input', ['$http', 'apiUrl', function($http, api) {
    return {
      loadUrl: function(url) {
        return $http.post(api + 'input/url', { 'url': url }).then(function(responce) {
          return responce.data.content;
        });
      }
    };
  }]);
