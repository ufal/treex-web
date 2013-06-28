'use strict';

describe('Controller: InputUrlCtrl', function () {

  // load the controller's module
  beforeEach(module('TreexWebApp'));

  var InputUrlCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    InputUrlCtrl = $controller('InputUrlCtrl', {
      $scope: scope
    });
  }));
});
