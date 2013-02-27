// TODO(vojta): improve, this is lame
var parseProvideRequire = function(str) {
  var provides = [];
  var requires = [];
  var match;

  str.split('\n').forEach(function(line) {
    match = line.match(/goog\.provide\([\"\'](.*)[\"\']\)/);
    if (match) {
      provides.push(match[1]);
    }

    match = line.match(/goog\.require\([\"\'](.*)[\"\']\)/);
    if (match) {
      requires.push(match[1]);
    }
  });

  return {
    provides: provides.sort(),
    requires: requires.sort()
  };
};


var equalSorted = function(a, b) {
  if (a.length !== b.length) {
    return false;
  }

  for (var i = 0, length = a.length; i < length; i++) {
    if (a[i] !== b[i]) {
      return false;
    }
  }

  return true;
};

var diffSorted = function(a, b) {
  var added = [];
  var removed = [];

  var i = 0;
  var j = 0;

  while (i < a.length && j < b.length) {
    if (a[i] === b[j]) {
      i++;
      j++;
    } else if (a[i] < b[j]) {
      removed.push(a[i]);
      i++;
    } else {
      added.push(b[j]);
      j++;
    }
  }

  while (i < a.length) {
    removed.push(a[i]);
    i++;
  }

  while (j < b.length) {
    added.push(b[j]);
    j++;
  }

  return !added.length && !removed.length ? null : {
    added: added,
    removed: removed
  };
};

var DependencyResolver = function() {
  this.removeFile = function(filepath) {

  };

  this.updateFile = function(filepath, content) {

  };

  this.resolveFiles = function(files) {

  };
};


exports.parseProvideRequire = parseProvideRequire;
exports.equalSorted = equalSorted;
exports.diffSorted = diffSorted;
exports.DependencyResolver = DependencyResolver;
