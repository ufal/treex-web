'use strict';

describe('Directive: twDownload', function () {
  beforeEach(module('TreexWebApp'));

  var element;

  it('should make hidden element visible', inject(function ($rootScope, $compile) {
    element = angular.element('<tw-download></tw-download>');
    element = $compile(element)($rootScope);
    expect(element.text()).toBe('this is the twDownload directive');
  }));
});
