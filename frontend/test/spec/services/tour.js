'use strict';

describe('Service: tour', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var tour;
  beforeEach(inject(function(_Tour_) {
    tour = _Tour_;
  }));

  it('should do something', function () {
    expect(!!tour).toBe(true);
  });

});
