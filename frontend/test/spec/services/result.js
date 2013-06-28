'use strict';

describe('Service: result', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var result;
  beforeEach(inject(function(_Result_) {
    result = _Result_;
  }));

  it('should do something', function () {
    expect(!!result).toBe(true);
  });

});
