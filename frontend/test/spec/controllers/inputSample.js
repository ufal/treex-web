'use strict';

describe('Controller: InputSampleCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var InputSampleCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    InputSampleCtrl = $controller('InputSampleCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
