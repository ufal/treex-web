'use strict';

describe('Controller: ScenarioPickCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var ScenarioPickCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ScenarioPickCtrl = $controller('ScenarioPickCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
