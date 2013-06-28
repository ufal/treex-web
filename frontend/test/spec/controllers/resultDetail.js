'use strict';

describe('Controller: ResultDetailCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var ResultDetailCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ResultDetailCtrl = $controller('ResultDetailCtrl', {
      $scope: scope
    });
  }));
});
