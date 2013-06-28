'use strict';

describe('Filter: noHtml', function () {

  // load the filter's module
  beforeEach(module('TreexWebApp'));

  // initialize a new instance of the filter before each test
  var noHtml;
  beforeEach(inject(function($filter) {
    noHtml = $filter('noHtml');
  }));

  it('should return the input prefixed with "noHtml filter:"', function () {
    var text = 'angularjs';
    expect(noHtml(text)).toBe('noHtml filter: ' + text);
  });

});
