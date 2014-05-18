'use strict';

angular.module('TreexWebApp')
  .factory('Result', ['$http', '$q', 'apiUrl', function($http, $q, api) {
    function Result(data) {
      angular.copy(data || {}, this);
      if (data) {
        if (!this.name) this.name = 'Run '+this.id;
        this.downloadAllUrl = 'results/' + this.token + '/download';
        this.downloadResultUrl = this.downloadAllUrl + '/result';
        this.downloadInputUrl = this.downloadAllUrl + '/input';
        this.downloadOutputUrl = this.downloadAllUrl + '/output';
        this.downloadScenarioUrl = this.downloadAllUrl + '/scenario';
      }
    }

    function asyncCall(method, token) {
      if (!token) {
        var fake = $q.defer();
        fake.resolve({});
        return fake.promise;
      }
      var promise = $http[method](api + 'results/' + token);
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
      var promise = $http.get(api + 'results/' + token + '/' + cmd);
      return promise.then(function(responce) {
        return responce.data[cmd] || df;
      });

    }

    Result.query = function() {
      var promise = $http.get(api + 'results');
      return promise.then(function(responce) {
        var result = [];
        angular.forEach(responce.data, function(item){
          result.push(new Result(item));
        });
        return result;
      });
    };

    Result.lastResult = new Result();
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

    angular.forEach(['input', 'output', 'error', 'scenario', 'print'], function(name) {
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
  }]);
