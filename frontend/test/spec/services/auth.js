'use strict';

describe('Service: auth', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var auth;
  beforeEach(inject(function(_Auth_) {
    auth = _Auth_;
  }));

  it('should do something', function () {
    expect(!!auth).toBe(true);
  });

});
