'use strict';

angular.module('TreexWebApp')
  .directive('twView', ['$rootScope', function($rootScope) {
    return {
      restrict: 'A',
      scope: {
        result: '=twView'
      },
      controller: ['$element', function($element) {
        this.$view = null;
        this.$sentence = null;
        this.$doc = null;

        this.nextBundle = function() {
          var view = this.$view;
          if (view && view.hasNextBundle()) {
            view.nextBundle();
            this.change();
          }
        };

        this.previousBundle = function() {
          var view = this.$view;
          if (view && view.hasPreviousBundle()) {
            view.previousBundle();
            this.change();
          }
        };

        this.change = function(fn) {
          if (fn) {
            $element.bind('change', fn);
          } else {
            $element.trigger('change');
          }
        };
      }],
      link : function(scope, element, attrs, cntl) {
        scope.$watch('result.job.status', function(value) {
          if (cntl.$view != null || value != 'completed') return;

          var result = scope.result;
          result.$print().then(function(data) {
            cntl.$view = Treex.TreeView(element[0]);
            cntl.$doc = Treex.Document.fromJSON(data);
            cntl.$view.init(cntl.$doc);
            if (cntl.$sentence)
              cntl.$view.description(cntl.$sentence);
            cntl.$view.drawBundle();
            $rootScope.$broadcast('treex:rendered');
          }, function(error) {
            $rootScope.$broadcast('treex:rendered');
          });
        });
      }
    };
  }]).
  directive('twViewPager', function() {
    return {
      restrict: 'A',
      require: '^twView',
      link : function(scope, element, attrs, cntl) {
        cntl.change(function() { // on view change
          if (cntl.$view) {
            scope.hasPreviousBundle = cntl.$view.hasPreviousBundle();
            scope.hasNextBundle = cntl.$view.hasNextBundle();
            scope.$apply();
          }
        });
        element.find('.prevBundle').bind('click', function(e) {
          e.stopPropagation();
          cntl.previousBundle();
        });
        element.find('.nextBundle').bind('click', function(e) {
          e.stopPropagation();
          cntl.nextBundle();
        });

        scope.$on('treex:rendered', function() {
          if (cntl.$doc && cntl.$doc.bundles.length > 1) {
            element.show();
            scope.hasPreviousBundle = cntl.$view.hasPreviousBundle();
            scope.hasNextBundle = cntl.$view.hasNextBundle();
          } else {
            element.hide();
          }
        });
      }
    };
  }).
  directive('twViewSentence', function() {
    return {
      restrict: 'A',
      require: '^twView',
      link : function(scope, element, attrs, cntl) {
        cntl.$sentence = element[0];
      }
    };
  }).
  directive('twViewLoading', function() {
    return {
      restrict: 'A',
      require: '^twView',
      link : function(scope, element, attrs, cntl) {
        scope.$on('treex:rendered', function() {
          element.hide();
        });
      }
    };
  });
