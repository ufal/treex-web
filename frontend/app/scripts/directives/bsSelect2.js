'use strict';

angular.module('TreexWebApp')
  .directive('bsSelect2', ['$timeout', function($timeout) {
    return {
      require: ['select', 'ngModel'],
      link: function(scope, element, attrs, cntls) {
        if (!cntls[1]) return;
        var clear = false,
            selectCntl = cntls[0],
            modelCntl = cntls[1],
            isMultiple = (attrs.multiple !== undefined);

        // watch the model for programmatic changes
        modelCntl.$render = function() {
          var val = !modelCntl.$viewValue ? (isMultiple ? [] : null) : angular.copy(modelCntl.$viewValue);
          element.select2('val', val, true);
        };

        if (selectCntl.databound) {
          scope.$watch(selectCntl.databound, function(value) {
            element.select2('val', !value ? (isMultiple ? [] : null) : value, false);
          });
        }
        element.select2(element.data());
        modelCntl.$render();
      }
    };
  }]);
