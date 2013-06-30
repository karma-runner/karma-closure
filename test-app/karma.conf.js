module.exports = function(config) {
  config.set({
    frameworks: ['jasmine', 'closure'],
    files: [
      // closure base
      {pattern: 'lib/goog/base.js'},
      // included files - tests
      {pattern: 'test/*.js'},
      // these are only watched and served
      {pattern: 'js/*.js', included: false},
      // external deps
      {pattern: 'lib/goog/deps.js', included: false, served: false}
    ],

    preprocessors: {
      'test/*.js': ['closure', 'closure-iit'],
      'js/*.js': ['closure'],
      'lib/goog/deps.js': ['closure-deps']
    },

    browsers: ['Chrome'],
    autoWatch: true
  });
};
