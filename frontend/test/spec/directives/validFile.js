'use strict';

describe('Directive: validFile', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<valid-file></valid-file>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the validFile directive');
  }));
});
