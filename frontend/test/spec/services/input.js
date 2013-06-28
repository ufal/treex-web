'use strict';

describe('Service: input', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var input;
  beforeEach(inject(function(_Input_) {
    input = _Input_;
  }));

  it('should do something', function () {
    expect(!!input).toBe(true);
  });

});
