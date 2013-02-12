'use strict';

/* Services */
var api = '/api/v1/';

angular.module('treex-services', ['ngResource']).
    factory('Results', ['$http', function($http) {
        var Results = {};
        Results.query = function() {
            var promise = $http.get(api + 'results');
            return promise.then(function(responce) {
                return responce.data;
            });
        };
        return Results;
    }]).
    value('version', '0.1');
