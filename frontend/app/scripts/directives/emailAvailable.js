'use strict';

angular.module('TreexWebApp')
  .directive('emailAvailable', [ '$timeout', 'User', function($timeout, User) {
    var promise;
    return {
      require: 'ngModel',
      link: function(scope, elm, attrs, cntl) {
        cntl.$parsers.unshift(function(viewValue) {
          if (promise) $timeout.cancel(promise);
          promise = $timeout(function() {
            User.emailAvailable(viewValue).then(function(available) {
              console.log(available);
              cntl.$setValidity('available', available);
            }, function() {
              cntl.$setValidity('available', true);
              cntl.$setValidity('email', false);
            });
          }, 200);
          return viewValue;
        });
      }
    };
  }]);
