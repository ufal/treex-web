// Karma configuration

// base path, that will be used to resolve files and exclude
basePath = '';

// list of files / patterns to load in the browser
files = [
  JASMINE,
  JASMINE_ADAPTER,
  'app/bower_components/jquery/jquery.js',
  'app/scripts/jquery.ui.widget.js',
  'app/bower_components/d3/d3.js',
  'app/scripts/angular/angular.js',
  'app/scripts/angular/angular-strap.js',
  'app/scripts/angular/angular-resource.js',
  'app/scripts/angular/angular-route.js',
  'app/scripts/angular/angular-http-auth.js',
  'app/scripts/angular/angular-mocks.js',
  'app/scripts/jquery.fileupload.js',
  'app/scripts/jquery.fileupload-process.js',
  'app/scripts/jquery.fileupload-validate.js',
  'app/scripts/jquery.fileupload-angular.js',
  'app/scripts/treex.js',
  'app/scripts/treeview.js',
  'app/scripts/app.js',
  'app/scripts/config.js',
  'app/scripts/{controllers,directives,filters,services}/*.js',
  'test/mock/**/*.js',
  'test/spec/**/*.js'
];

// list of files to exclude
exclude = [];

// test results reporter to use
// possible values: dots || progress || growl
reporters = ['progress'];

// web server port
port = 8080;

// cli runner port
runnerPort = 9100;

// enable / disable colors in the output (reporters and logs)
colors = true;

// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;

// enable / disable watching file and executing tests whenever any file changes
autoWatch = false;

// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
browsers = ['Chrome'];

// If browser does not capture in given timeout [ms], kill it
captureTimeout = 5000;

// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = false;
