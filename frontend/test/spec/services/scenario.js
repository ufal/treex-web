'use strict';

describe('Service: scenario', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var scenario;
  beforeEach(inject(function(_scenario_) {
    scenario = _scenario_;
  }));

  it('should do something', function () {
    expect(!!scenario).toBe(true);
  });

});
