'use strict';

describe('Controller: RunTreexCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var RunTreexCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    RunTreexCtrl = $controller('RunTreexCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
