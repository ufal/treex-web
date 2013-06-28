'use strict';

describe('Controller: ScenarioDetailCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var ScenarioDetailCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ScenarioDetailCtrl = $controller('ScenarioDetailCtrl', {
      $scope: scope
    });
  }));
});
