'use strict';

describe('Controller: ScenarioListCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var ScenarioListCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ScenarioListCtrl = $controller('ScenarioListCtrl', {
      $scope: scope
    });
  }));
});
