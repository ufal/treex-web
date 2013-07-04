'use strict';

describe('Service: siteError', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var siteError;
  beforeEach(inject(function(_siteError_) {
    siteError = _siteError_;
  }));

  it('should do something', function () {
    expect(!!siteError).toBe(true);
  });

});
