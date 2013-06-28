'use strict';

describe('Filter: ucfirst', function () {

  // load the filter's module
  beforeEach(module('TreexWebApp'));

  // initialize a new instance of the filter before each test
  var ucfirst;
  beforeEach(inject(function($filter) {
    ucfirst = $filter('ucfirst');
  }));

  // it('should return the input prefixed with "ucfirst filter:"', function () {
  //   var text = 'angularjs';
  //   expect(ucfirst(text)).toBe('ucfirst filter: ' + text);
  // });

});
