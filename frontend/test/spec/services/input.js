'use strict';

describe('Service: input', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var input;
  beforeEach(inject(function(_input_) {
    input = _input_;
  }));

  it('should do something', function () {
    expect(!!input).toBe(true);
  });

});
