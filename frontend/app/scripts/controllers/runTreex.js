'use strict';

angular.module('TreexWebApp').controller(
  'RunTreexCtrl',
  ['$scope', '$location', '$anchorScroll', '$timeout', '$http', 'Treex', 'Result', 'Scenario', 'Tour', 'apiUrl',
   function($scope, $location, $anchorScroll, $timeout, $http, Treex, Result, Scenario, Tour, apiUrl) {

     if (Tour.isRunning()) {
       Tour.showStep(1);
       Result.lastResult = null;

       $scope.$watch('query.scenario', function(value) {
         if (angular.isString(value) && value.length > 20) {
           Tour.showStep(2);
         } else {
           Tour.showStep(1);
         }
       });
     }

     $scope.query = Result.lastResult || (Result.lastResult = new Result());

     // constructor for uploaded file
     function uploadedFile(file) {
       var scope = $scope;
       if (file.url) {
         var state;
         scope.query.filename = file.filename;
         file.$state = function () {
           return state;
         };
         file.$destroy = function() {
           state = 'pending';
           return $http({
             url: apiUrl + file.deleteUrl,
             method: file.deleteType
           }).then(
             function () {
               state = 'resolved';
               scope.clear(file);
               if (scope.query.filename == file.filename) {
                 scope.query.filename = '';
               }
             },
             function () {
               state = 'rejected';
             }
           );
         };
       } else if (!file.$cancel && !file._index) {
         file.$cancel = function () {
           scope.clear(file);
         };
       }
     }

     if (!$scope.query.input) {
       $scope.queue = $http.get(apiUrl + '/query/upload').success(function(data) {
         angular.forEach(data.files, uploadedFile);
         var file = data.files[0];
         if (file && !$scope.query.input) {
           $scope.query.filename = file.filename;
         }
         $scope.queue = data.files;
       });
     }

     $scope.$watch('query.compose', function(value) {
       if (value && $scope.ace) {
         if (!$scope.query.scenario) {
           $scope.query.scenario = Scenario.$template;
         }
         $timeout(function() {
           $scope.ace.resize(true);
           $scope.ace.focus();
         });
       }
     });

     $scope.$watch('query.input', function(value) {
       if (value) {
         angular.forEach($scope.queue, function(file) {
           if (file.$destroy) {
             file.$destroy();
           } else {
             file.$cancel();
           }
         });
       }
     });

     if ($scope.query.scenario) {
       $scope.query.compose = true;
     }

     $scope.clearForm = function() {
       $scope.query = Result.lastResult = new Result();
       angular.forEach($scope.queue, function(file) {
         if (file.$destroy) {
           file.$destroy();
         } else {
           file.$cancel();
         }
       });
       if (Tour.isRunning()) {
         Tour.showStep(1);
       }
     };

     $scope.submit = function() {
       if ($scope.form.$invalid) return;
       var q = $scope.query;
       Treex.query({
         scenario: q.scenario,
         scenario_name: q.name,
         input: q.input
       }).then(function(result) {
         Result.lastResult = null;
         $location.path('/result/'+result.token);
       }, function(reason) {
         $scope.error = angular.isObject(reason.data) ?
           reason.data.error : reason.data;
         $anchorScroll('query-error');
       });
     };

     // TODO: move this somewhere else
     $scope.upload = {
       url: apiUrl + 'query/upload',
       acceptFileTypes: /(\.|\/)(txt|treex|conll)(\.gz)?$/i,
       maxFileSize: 5000000, // 5MB
       //maxNumberOfFiles: 1,
       autoUpload: true,
       formData: function(form) { return ''; },
       add: function (e, data) {
         var scope = data.scope();
         data.process(function () {
           return scope.process(data);
         }).always(
           function () {
             var file = data.files[0],
                 submit = function () {
                   return data.submit();
                 },
                 i;
             for (i = 0; i < data.files.length; i += 1) {
               data.files[i]._index = i;
             }
             file.$cancel = function () {
               scope.clear(data.files);
               return data.abort();
             };
             file.$state = function () {
               return data.state();
             };
             file.$progress = function () {
               return data.progress();
             };
             file.$response = function () {
               return data.response();
             };
             if (file.$state() === 'rejected') {
               file._$submit = submit;
             } else {
               file.$submit = submit;
             }
             scope.$apply(function () {
               angular.forEach(scope.queue, function(file) {
                 if (file.$destroy) {
                   file.$destroy();
                 } else {
                   file.$cancel();
                 }
               });
               scope.queue.length = 0;
               scope.queue.push(file);
               if (file.$submit &&
                   (scope.option('autoUpload') ||
                    data.autoUpload) &&
                   data.autoUpload !== false) {
                 file.$submit();
               }
             });
           }
         );
       },
       handleResponse: function(e, data) {
         var scope = data.scope(),
             file = data.result && data.result.files[0];
         if (file) {
           scope.replace(data.files, data.result.files);
           scope.query.input = '';
           uploadedFile(file);
         } else if (data.errorThrown ||
                    data.textStatus === 'error') {
           data.files[0].error = data.errorThrown ||
             data.textStatus;
         }
       }
     };

   }]);
