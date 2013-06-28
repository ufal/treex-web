'use strict';

describe('Directive: bsRowlink', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<bs-rowlink></bs-rowlink>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the bsRowlink directive');
  }));
});
