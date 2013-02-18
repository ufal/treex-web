'use strict';

/* Services */
var api = '/api/v1/';

angular.module('treex-services', ['ngResource']).
    factory('Result', ['$http', '$q', function($http, $q) {
        function Result(data) {
            angular.copy(data || {}, this);
            if (!this.name) this.name = this.token;
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
        Result.job = function(token) {
            return asyncCall('get', token + '/status');
        };
        Result.prototype.$delete = function() { return Result.delete(this.token); };
        Result.prototype.$job = function() {
            var self = this;
            return Result.job(this.token).
                then(function(job) {
                    self.job = job;
                    return job;
                });
        };

        Result.prototype.$updatePending = function() {
            if (this.job && this.job.status != 'queued' && this.job.status != 'working')
                return false;
            this.$job();
            return true;
        };

        angular.forEach(['input', 'error', 'scenario', 'print'], function(name) {
            var has = 'has' + name.charAt(0).toUpperCase() + name.slice(1);
            Result.prototype['$'+name] = function() {
                var self = this;
                return self[has] ?
                    self[name] : self[name] = asyncCmd(this.token, name, '').then(function(data) {
                        self[has] = true;
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
    factory('Scenario', ['$resource', function($resource) {
        return $resource(api + 'scenario/:id');
    }]).
    factory('Scenarios', ['$http', 'Scenario', function($http, Scenario) {
        return {
            query: function(language) {
                var promise = $http.get(api + 'scenarios', {
                    params : { language : (angular.isObject(language) ? language.value : language) }
                });
                return promise.then(function(responce) {
                    var result = [];
                    console.log(responce.data);
                    angular.forEach(responce.data, function(item){
                        result.push(new Scenario(item));
                    });
                    return result;
                });
            }
        };
    }]).
    factory('Input', ['$http', function($http) {
        return {
            loadUrl: function(url) {
                return $http.post(api + 'input/url', { 'url': url }).then(function(responce) {
                    return responce.data.content;
                });
            }
        };
    }]).
    factory('Treex', ['$http', 'Result', function($http, Result) {
        var languages;
        return {
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
                        var result = [];
                        angular.forEach(responce.data, function(group) {
                            angular.forEach(group.options, function(opt) {
                                opt.group = group.group;
                                result.push(opt);
                            });
                        });
                        return result;
                    });
            }
        };
    }]).
    value('version', '0.1');
