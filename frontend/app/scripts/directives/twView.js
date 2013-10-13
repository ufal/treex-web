'use strict';

angular.module('TreexWebApp')
  .directive('twView', ['$rootScope', function($rootScope) {
    return {
      restrict: 'A',
      scope: {
        result: '=twView'
      },
      controller: ['$element', '$scope', function($element, $scope) {
        var self = this, lastBundle = 0, bundleChange = false;
        self.$view = null;
        self.$sentence = null;
        self.$doc = null;
        self.$element = null;

        this.setDocument = function(doc) {
          this.$doc = doc;
          $scope.noOfPages = doc.bundles.length;
          $scope.currentPage = 1;
        };

        this.selectNode = function(node) {
          $scope.selectedNode = node ? node : null;
          if (!bundleChange) {
            $scope.$apply();
          }
        };

        $scope.$watch('currentPage', function(value) {
          self.setBundle(value-1);
        });

        this.setBundle = function(bundle) {
          var view = this.$view;
          if (view && bundle !== lastBundle) {
            bundleChange = true;
            view.setBundle(bundle);
            lastBundle = bundle;
            this.change();
            bundleChange = false;
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
          if (cntl.$view !== null ||
              value !== 'completed' ||
              cntl.$element === null ||
              !scope.result.printable) {
            return;
          }

          var result = scope.result;
          result.$print().then(function(data) {
            if (!data || data.length === 0) {
              $rootScope.$broadcast('treex:rendered');
              return;
            }
            cntl.$view = Treex.TreeView(cntl.$element);
            cntl.setDocument(Treex.Document.fromJSON(data));
            cntl.$view.init(cntl.$doc);
            cntl.$view.onNodeSelect(cntl.selectNode);
            if (cntl.$sentence) {
              cntl.$view.description(cntl.$sentence);
            }
            cntl.$view.drawBundle();
            $rootScope.$broadcast('treex:rendered');
          }, function() {
            $rootScope.$broadcast('treex:rendered');
          });
        });
      }
    };
  }]).
  directive('twViewGraphics', function() {
    return {
      restrict: 'A',
      require: '^twView',
      link : function(scope, element, attrs, cntl) {
        cntl.$element = element[0];
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
  directive('twViewAttributes', function() {
    return {
      restrict: 'A',
      scope: {
        node: '=twViewAttributes'
      },
      link : function(scope) {
        scope.$watch('node', function(node) {
          if (!node) {
            scope.attributes = null;
            return;
          }

          var id = node.uid,
              attributes = node.data;

          function formatAttributes(attrs) {
            var ar = [];
            for (var key in attrs) {
              var val = attrs[key];
              if (angular.isObject(val)) {
                continue;
              }
              ar.push({
                name: key,
                value: val,
                id: id+'_'+key
              });
            }
            return ar;
          }
          scope.attributes = formatAttributes(attributes);
        });
      }
    };
  }).
  directive('twViewLoading', function() {
    return {
      restrict: 'A',
      require: '^twView',
      link : function(scope, element) {
        scope.$on('treex:rendered', function() {
          element.hide();
        });
      }
    };
  });
