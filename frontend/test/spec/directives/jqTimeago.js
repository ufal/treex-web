'use strict';

describe('Directive: jqTimeago', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<jq-timeago></jq-timeago>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the jqTimeago directive');
  }));
});
