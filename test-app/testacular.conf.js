frameworks = ['jasmine', 'closure'];

files = [
  // closure base
  {pattern: 'lib/goog/base.js'},

  // included files
  {pattern: 'test/*.js', preprocessors: ['closure', 'closure-iit']},

  // these are only watched and served
  {pattern: 'js/*.js', included: false, preprocessors: ['closure']},

  // external deps
  {pattern: 'lib/goog/deps.js', included: false, served: false, preprocessors: ['closure-deps']}
];

plugins = [
  'closure-deps-resolver',
  'testacular-jasmine',
  'testacular-chrome-launcher'
];

autoWatch = true;
