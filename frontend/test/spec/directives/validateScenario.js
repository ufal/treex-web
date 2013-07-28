'use strict';

describe('Directive: validateScenario', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<validate-scenario></validate-scenario>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the validateScenario directive');
  }));
});
