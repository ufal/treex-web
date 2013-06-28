'use strict';

describe('Service: treex', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var treex;
  beforeEach(inject(function(_Treex_) {
    treex = _Treex_;
  }));

  it('should do something', function () {
    expect(!!treex).toBe(true);
  });

});
