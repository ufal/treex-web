'use strict';

angular.module('TreexWebApp')
  .controller(
    'AuthCtrl',
    ['$scope', '$rootScope', '$timeout', '$location', '$modal', '$window', 'authService', 'Auth',
     function($scope, $rootScope, $timeout, $location, $modal, $window, authService, Auth) {
       var modal = null;
       var modalScope = $rootScope.$new();

       function successfulPing(data) {
         if (!data.id) {
           return;
         }
         $rootScope.$broadcast('auth:loginConfirmed');
       }

       Auth.ping().success(successfulPing);

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

       function layoutModal() {
         if (!modal) {
           return;
         }
         $timeout(function() {
           modal.modal('layout');
         });
       }

       // TODO: rewrite this variable mess to some object stuff
       angular.forEach(['error', 'localAccount', 'noMetadata', 'loginFailed'], function(val) {
         modalScope.$watch(val, layoutModal);
       });

       modalScope.$watch('loginSuccess', function(value) {
         if (value) {
           modalScope.hideLoginChoice = true;
           layoutModal();
           Auth.ping().success(function(data) {
             successfulPing(data);
             modalScope.hideLoginChoice = false;
             angular.forEach(['noMetadata', 'loginFailed', 'loginSuccess', 'localAccount', 'error'], function(val) {
               modalScope[val] = false;
             });
           }).error(function() {
             modalScope.hideLoginChoice = false;
             modalScope.loginSuccess = false;
             modalScope.loginFailed = true;
           });
         }
       });

       modalScope.login = function() {
         Auth.login(modalScope.auth)
           .success(function() {
             authService.loginConfirmed();
           })
           .error(function(data) {
             modalScope.error = data.error;
           });
       };

       modalScope.discojuice = function() {
         var frame = $('<iframe/>');
         frame.appendTo($('body'));
         frame.css({
           position: 'absolute',
           'z-index': '1099',
           border: '0',
           width: '100%',
           height: '100%',
           left: '0',
           top: '0'
         });
         frame.attr('src', 'login.html');
         $window.closeIframe = function() {
           frame.remove();
           // clean up global functions
           angular.forEach(['closeIframe', 'noMetadata', 'loginFailed', 'loginSuccess'], function(val) {
             delete $window[val];
           });
           modalScope.$apply();
         };
         angular.forEach(['noMetadata', 'loginFailed', 'loginSuccess'], function(val) {
           $window[val] = function() {
             modalScope[val] = true;
             $window.closeIframe();
           };
         });
       };

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
             if (!$rootScope.loggedIn) {
               m.modal('show');
             }
           });
         }
       }

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
