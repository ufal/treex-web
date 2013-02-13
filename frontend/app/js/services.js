'use strict';

/* Services */
var api = '/api/v1/';

angular.module('treex-services', ['ngResource']).
    factory('Result', ['$http', '$q', function($http, $q) {
        function Result(data) {
            angular.copy(data || {}, this);
        }

        function asyncCall(method, token) {
            if (!token) {
                var fake = $q.defer();
                fake.resolve({});
                return fake.promise;
            }
            var promise = $http[method](api + 'result/' + token);
            return promise.then(function(responce) {
                return new Result(responce.data);
            });
        }

        function asyncCmd(token, cmd, df) {
            if (!token) {
                var fake = $q.defer();
                fake.resolve(df);
                return fake.promise;
            }
            var promise = $http.get(api + 'result/' + token + '/' + cmd);
            return promise.then(function(responce) {
                return responce.data[cmd] || df;
            });

        }

        Result.get = function(token) { return asyncCall('get', token); };
        Result.delete = function(token) { return asyncCall('delete', token); };
        Result.status = function(token) {
            return asyncCmd(token, 'status', 'unknown');
        };
        Result.prototype.$delete = function() { return Result.delete(this.token); };
        Result.prototype.$status = function() {
            var self = this;
            return Result.status(this.token).
                then(function(status) {
                    self.status = status;
                    return status;
                });
        };

        Result.prototype.$updatePending = function() {
            if (this.status != 'pending')
                return false;
            this.$status();
            return true;
        };

        angular.forEach(['input', 'error', 'scenario', 'print'], function(name) {
            var has = 'has' + name.charAt(0).toUpperCase() + name.slice(1);
            Result.prototype['$'+name] = function() {
                var self = this;
                return self[has] ?
                    self[name] : asyncCmd(this.token, name, '').then(function(data) {
                        self[has] = true;
                        self[name] = data;
                        return data;
                    });
            };
        });

        return Result;
    }]).
    factory('Results', ['$http', 'Result', function($http, Result) {
        var Results = {};
        Results.query = function() {
            var promise = $http.get(api + 'results');
            return promise.then(function(responce) {
                var result = [];
                angular.forEach(responce.data, function(item){
                    result.push(new Result(item));
                });
                return result;
            });
        };
        return Results;
    }]).
    value('version', '0.1');
