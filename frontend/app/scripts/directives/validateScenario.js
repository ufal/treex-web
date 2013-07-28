'use strict';

angular.module('TreexWebApp')
  .directive('validateScenario', [function() {
    return {
      require: 'ngModel',
      link: function(scope, elm, attrs, model) {

        function extractExtension(filename) {
          return filename ? filename.match(/\.(\w+)(\.gz)?$/)[1] : '';
        }

        function check(scenario, input, inputFile) {
          var errors = {}, e = [];
          angular.forEach(['missingRead', 'missingWrite', 'readMatch', 'readSupport'], function(val) {
            var o = errors[val] = {
              name: val,
              valid: true
            };
            e.push(o);
          });

          if (!/Read::(\w+)/.test(scenario)) {
            errors['missingRead'].valid = false;
          } else if (input) {
            if (inputFile) {
              var ext = extractExtension(inputFile);
              var check = {
                txt: /Read::(Text|Sentences)/,
                treex: /Read::Treex/,
                conll: /Read::ConllX/,
                conllx: /Read::ConllX/
              };
              if (check[ext] && !check[ext].test(scenario)) {
                errors['readMatch'].valid = false;
              }
            } else if (!/Read::(Text|Sentences)/.test(scenario)) {
              errors['readSupport'].valid = false;
            }
          }

          if (!/Write::(\w+)/.test(scenario)) {
            errors['missingWrite'].valid = false;
          }

          return e;
        };

        function adjustReadBlock(scenario, filename) {
          // extract extension
          var ext = extractExtension(filename)||'txt';

          if (/Read::(\w+)/.test(scenario)) {
            if (ext == 'txt') {
              return scenario.replace(/Read::(Treex|ConllX)/, 'Read::Text');
            } else if (ext == 'treex') {
              return scenario.replace(/Read::\w+/, 'Read::Treex');
            } else if (ext == 'conll' || ext == 'conllx') {
              return scenario.replace(/Read::\w+/, 'Read::ConllX');
            }
          }

          return scenario;
        };

        attrs.$observe('inputFile', function(value) {
          model.$setViewValue(adjustReadBlock(model.$viewValue, value));
        });

        function validateScenario (viewValue) {
          var file = attrs.inputFile,
              input = !!attrs.input,
              errors = check(viewValue, input, file);
          for (var i = 0, ii = errors.length; i < ii; i++) {
            var error = errors[i];
            model.$setValidity(error.name, error.valid);
          }
          return viewValue;
        }

        model.$parsers.unshift(validateScenario);
        model.$formatters.unshift(validateScenario);
      }
    };
  }]);
