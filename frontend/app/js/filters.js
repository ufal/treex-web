'use strict';

/* Filters */

angular.module('treex-filters', []).
    filter('interpolate', ['version', function(version) {
        return function(text) {
            return String(text).replace(/\%VERSION\%/mg, version);
        };
    }]).
    filter('newlines', function() {
        return function(text) {
            if (!text) return '';
            return text.replace(/\n/g, '<br />');
        };
    }).
    filter('noHTML', function() {
        return function(text) {
            if (!text) return '';
            return text
                .replace(/&/g, '&amp;')
                .replace(/>/g, '&gt;')
                .replace(/</g, '&lt;');
        };
    }).
    filter('ucfirst', function() {
        return function(text) {
            return String(text).charAt(0).toUpperCase() + String(text).slice(1);
        };
    });
