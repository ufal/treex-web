'use strict';

describe('Service: auth', function () {

  // load the service's module
  beforeEach(module('TreexWebApp'));

  // instantiate services
  var Auth, $httpBackend, $rootScope, apiUrl;

  beforeEach(inject(function(_Auth_, _$httpBackend_, _$rootScope_, _apiUrl_) {
    Auth = _Auth_;
    $httpBackend = _$httpBackend_;
    $rootScope = _$rootScope_;
    apiUrl = _apiUrl_;
  }));

  afterEach(function() {
    $httpBackend.verifyNoOutstandingExpectation();
    $httpBackend.verifyNoOutstandingRequest();
  });

  it('should store redirect url', function() {
    Auth.redirectAfterLogin('/some/url');
    expect(Auth.redirectAfterLogin()).toBe('/some/url');
  });

  it('should fail ping if not logged in', function () {
    $httpBackend.expectGET(apiUrl+'auth').respond(404);
    Auth.ping();
    $httpBackend.flush();
    expect(Auth.loggedIn()).toBe(false);
  });

});
