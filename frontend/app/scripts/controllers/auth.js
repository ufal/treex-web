'use strict';

angular.module('TreexWebApp')
  .controller(
    'AuthCtrl',
    ['$scope', '$rootScope', '$timeout', '$location', '$modal', '$window', 'authService', 'Auth',
     function($scope, $rootScope, $timeout, $location, $modal, $window, authService, Auth) {
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
         angular.forEach(['noMetadata', 'loginFailed', 'loginSuccess'], function(val) {
           $window[val] = function() {
             $window.closeIframe();
           };
         });
         $window.closeIframe = function() {
           frame.remove();
         };
       };

       var layout = function() {
         if (!modal) return;
         $timeout(function() {
           modal.modal('layout');
         });
       };

       modalScope.$watch('error', layout);
       modalScope.$watch('localAccount', layout);

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
