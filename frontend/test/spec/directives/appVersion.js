'use strict';

describe('Directive: appVersion', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<app-version></app-version>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the appVersion directive');
  }));
});
