'use strict';

describe('Directive: emailAvailable', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<email-available></email-available>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the emailAvailable directive');
  }));
});
