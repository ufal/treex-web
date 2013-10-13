'use strict';

angular.module('TreexWebApp')
  .filter('formatAttributes', function () {

    return function (node) {
      if (!node) {
        return [];
      }
      var id = node.uid,
          attributes = node.data;

      function formatAttributes(attrs) {
        var ar = [];
        for (var key in attrs) {
          var val = node[key];
          ar.push({
            name: key,
            value: angular.isObject(val) ? formatAttributes(val) : val,
            id: id+'_'+key
          });
        }
        return ar;
      }
      return formatAttributes(attributes);
    };
  });
