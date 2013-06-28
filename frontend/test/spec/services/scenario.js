'use strict';

describe('Scenario', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate service
  var scenario;
  beforeEach(inject(function(_Scenario_) {
    scenario = _Scenario_;
    console.log(scenario);
  }));

  it('should do something', function () {
    expect(!!scenario).toBe(true);
  });

});
