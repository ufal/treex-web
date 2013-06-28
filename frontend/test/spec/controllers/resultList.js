'use strict';

describe('Controller: ResultListCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var ResultListCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ResultListCtrl = $controller('ResultListCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
