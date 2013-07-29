'use strict';

angular.module('TreexWebApp')
  .directive('twView', ['$rootScope', function($rootScope) {
    return {
      restrict: 'A',
      scope: {
        result: '=twView'
      },
      controller: ['$element', '$scope', function($element, $scope) {
        var self = this, lastBundle = 0;
        this.$view = null;
        this.$sentence = null;
        this.$doc = null;

        this.setDocument = function(doc) {
          this.$doc = doc;
          $scope.noOfPages = doc.bundles.length;
          $scope.currentPage = 1;
        };

        $scope.$watch('currentPage', function(value) {
          self.setBundle(value-1);
        });

        this.setBundle = function(bundle) {
          var view = this.$view;
          if (view && bundle != lastBundle) {
            view.setBundle(bundle);
            lastBundle = bundle;
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
          if (cntl.$view != null
              || value != 'completed'
              || !scope.result.printable) return;

          var result = scope.result;
          result.$print().then(function(data) {
            if (!data || data.length == 0) {
              $rootScope.$broadcast('treex:rendered');
              return;
            }
            cntl.$view = Treex.TreeView(element[0]);
            cntl.setDocument(Treex.Document.fromJSON(data));
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
