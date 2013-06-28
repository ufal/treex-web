'use strict';

describe('Directive: twIf', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<tw-if></tw-if>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the twIf directive');
  }));
});
