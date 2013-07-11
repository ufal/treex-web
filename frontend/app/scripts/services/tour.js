'use strict';

angular.module('TreexWebApp')
  .factory('Tour', [ '$rootScope', '$timeout', function(scope, $timeout) {
    var isRunning = false,
        element = '#site-tour',
        currentStep = 0,
        setting = {
          autoStart: true,
          nextButton: false,
          template: {
            link: '<a href="javascript:void(0)" class="joyride-close-tip">X</a>',
            button: '<a href="javascript:void(0)" class="joyride-next-tip"></a>'
          },
          postRideCallback : function() {
            console.log('stop');
            console.log(setting);
            isRunning = false;
          },
          preRideCallback : function() {
            console.log('start');
            console.log(setting);
            isRunning = true;
          }
        };

    scope.$on( '$routeChangeStart', function() {
      if (isRunning) {
        $(element).joyride('hide');
      }
    });

    return {
      start: function() {
        if (isRunning) return;
        currentStep = 0;
        $timeout(function() {
          $(element).joyride('destroy');
          $(element).joyride(angular.extend({ }, setting, {
            startOffset: 0
          }));
        });
      },
      end: function() {
        $(element).joyride('end');
      },
      isRunning: function() {
        return isRunning;
      },
      nextStep: function() {
        if (!isRunning) return;
        currentStep++;
        $timeout(function() {
          $(element).joyride('nextTip');
        });
      },
      showStep: function(step) {
        if (!isRunning || currentStep == step) return;
        currentStep = step;
        $timeout(function() {
          $(element).joyride('destroy');
          $(element).joyride(angular.extend({ }, setting, {
            startOffset: step
          }));
        });
      }
    };
  }]);
