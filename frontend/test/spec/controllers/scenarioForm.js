'use strict';

describe('Controller: ScenarioFormCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var ScenarioFormCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ScenarioFormCtrl = $controller('ScenarioFormCtrl', {
      $scope: scope
    });
  }));
});
