'use strict';

angular.module('TreexWebApp')
  .factory('Tour', [ '$timeout', function($timeout) {

    var isRunning = false,
        element = '#site-tour',
        setting = {
          autoStart: true,
          nextButton: false,
          template: {
            link: '<a href="javascript:" class="joyride-close-tip">X</a>',
            button: '<a href="javascript:" class="joyride-next-tip"></a>'
          },
          postRideCallback : function() {
            isRunning = false;
          },
          preRideCallback : function() {
            isRunning = true;
          }
        };

    return {
      start: function() {
        if (isRunning) return;
        $(element).joyride(setting);
      },
      isRunning: function() {
        return isRunning;
      },
      nextStep: function() {
        if (!isRunning) return;
        $timeout(function() {
          $(element).joyride('nextTip');
        });
      },
      showStep: function(step) {
        if (!isRunning) return;
        $timeout(function() {
          $(element).joyride('destroy');
          $(element).joyride(angular.extend(setting, {
            startOffset: step
          }));
        });
      }
    };
  }]);
