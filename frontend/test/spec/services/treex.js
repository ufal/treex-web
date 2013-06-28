'use strict';

describe('Service: treex', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var treex;
  beforeEach(inject(function(_treex_) {
    treex = _treex_;
  }));

  it('should do something', function () {
    expect(!!treex).toBe(true);
  });

});
