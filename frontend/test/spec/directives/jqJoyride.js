'use strict';

describe('Directive: jqJoyride', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<jq-joyride></jq-joyride>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the jqJoyride directive');
  }));
});
