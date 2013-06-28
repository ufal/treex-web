'use strict';

angular.module('TreexWebApp')
  .directive('validateSameAs', ['$parse', function($parse) {
    return {
      require: 'ngModel',
      link: function(scope, elm, attrs, cntl) {
        cntl.$parsers.unshift(function(viewValue) {
          var value = attrs['validateSameAs'];
          if (!value) return;
          var valueGet = $parse(value);
          if (valueGet(scope) == viewValue) {
            cntl.$setValidity('same', true);
            return viewValue;
          } else {
            cntl.$setValidity('same', false);
            return undefined;
          }
        });
      }
    };
  }]);
