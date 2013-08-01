'use strict';

angular.module('TreexWebApp')
  .controller(
    'AuthCtrl',
    ['$scope', '$rootScope', '$timeout', '$location', '$modal', 'authService', 'Auth',
     function($scope, $rootScope, $timeout, $location, $modal, authService, Auth) {
       var modal = null;
       var modalScope = $rootScope.$new();

       Auth.ping().success(function(data) {
         if (!data.id) return;
         $rootScope.$broadcast('auth:loginConfirmed');
       });

       $rootScope.loggedIn = false;

       $scope.$on('auth:loginRequired', function() {
         if (!$rootScope.loggedIn) {
           showLogin('forced');
         }
       });

       $scope.$on('auth:loginConfirmed', function(){
         $rootScope.loggedIn = true;
         if (modal && modal.modal) {
           modal.modal('hide');
         }
       });

       $scope.$on('auth:loggedOut', function(){
         $rootScope.loggedIn = false;
       });

       modalScope.auth = {
         email: 'treex@ufal.mff.cuni.cz',
         password: 'LetMeIn'
       };
       console.log(modalScope.auth);

       modalScope.login = function() {
         Auth.login(modalScope.auth)
           .success(function() {
             authService.loginConfirmed();
           })
           .error(function(data) {
             modalScope.error = data.error;
           });
       };

       modalScope.$watch('error', function(value) {
         if (!modal) return;
         $timeout(function() {
           modal.modal('layout');
         });
       });

       function showLogin(forced) {
         modalScope.forced = !!forced;
         if (modal) {
           modal.modal({
             backdrop: 'static',
             keyboard: false,
             persist: true
           });
         } else {
           getModal().then(function(m) {
             modal = m;
             if (!$rootScope.loggedIn)
               m.modal('show');
           });
         }
       };

       $scope.showLogin = function() {
         showLogin();
       };

       function getModal() {
         return $modal({
           template: 'views/auth/login.html',
           scope: modalScope,
           backdrop: 'static',
           keyboard: false,
           persist: true,
           show: false
         }).then(function(m) {
           m.on('hidden', function() {
             if (!$rootScope.loggedIn) {
               authService.loginFailed();
             }
             if (modalScope.auth) {
               delete modalScope.auth.password;
             }
             modalScope.error = '';
           });
           return m;
         });
       }
     }]);
