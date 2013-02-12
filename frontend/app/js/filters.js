'use strict';

/* Filters */

angular.module('treex-filters', []).
    filter('interpolate', ['version', function(version) {
        return function(text) {
            return String(text).replace(/\%VERSION\%/mg, version);
        };
    }]).
    filter('ucfirst', function() {
        return function(text) {
            return String(text).charAt(0).toUpperCase() + String(text).slice(1);
        };
    });
