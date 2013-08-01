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
});
