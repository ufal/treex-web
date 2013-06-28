'use strict';

describe('Directive: bsActiveTab', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<bs-active-tab></bs-active-tab>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the bsActiveTab directive');
  }));
});
