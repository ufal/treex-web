'use strict';

describe('Directive: twView', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<tw-view></tw-view>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the twView directive');
  }));
});
