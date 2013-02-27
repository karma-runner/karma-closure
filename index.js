var chokidar = require('chokidar');
var fs = require('q-io/fs');

// inputs
var WATCH = 'test-app/js';


var fileMap = Object.create(null);
var provideMap = Object.create(null);


var index = require('./lib/index');

var parseProvideRequire = index.parseProvideRequire;
var diffSorted = index.diffSorted;

// DependencyResolver

// state:
// - fileMap
// - provideMap
// - cacheFiles = cached resolved files
// - cacheId = array of included files

var updateProvideMap = function(filepath, oldProvides, newProvides) {
  oldProvides.forEach(function(dep) {
    provideMap[dep] = null;
  });

  newProvides.forEach(function(dep) {
    provideMap[dep] = filepath;
  });
};

var checkFile = function(filepath) {
  return fs.read(filepath).then(function(content) {
    var parsed = parseProvideRequire(content);

    if (!fileMap[filepath]) {
      console.log('New file', filepath, 'adding to the map.');
      console.log(parsed);
      updateProvideMap(filepath, [], parsed.provides);
      fileMap[filepath] = parsed;
      return;
    }

    var diffProvides = diffSorted(fileMap[filepath].provides, parsed.provides);
    var diffRequires = diffSorted(fileMap[filepath].requires, parsed.requires);

    if (diffProvides) {
      console.log('Provides change in', filepath);
      console.log('Added', diffProvides.added);
      console.log('Removed', diffProvides.removed);
    } else {
      console.log('No provides change in', filepath);
    }

    if (diffRequires) {
      console.log('Requires change in', filepath);
      console.log('Added', diffRequires.added);
      console.log('Removed', diffRequires.removed);
    } else {
      console.log('No requires change in', filepath);
    }

    updateProvideMap(filepath, fileMap[filepath].provides, parsed.provides);
    fileMap[filepath] = parsed;
  });
};

// TODO(vojta): handle circular deps
var resolveFile = function(filepath, files, alreadyResolvedMap) {
  // console.log('resolving', filepath);

  files = files || [];
  alreadyResolvedMap = alreadyResolvedMap || Object.create(null);

  // TODO(vojta): error if unknown file
  // resolve all dependencies first
  fileMap[filepath].requires.forEach(function(dep) {
    if (!alreadyResolvedMap[dep]) {
      // TODO(vojta): error if dep not provided
      resolveFile(provideMap[dep], files, alreadyResolvedMap);
    }
  });

  files.push(filepath);
  fileMap[filepath].provides.forEach(function(dep) {
    alreadyResolvedMap[dep] = true;
  });

  return files;
};

var pendingTimer = null;
var scheduleResolving = function() {
  if (pendingTimer) {
    return;
  }

  pendingTimer = setTimeout(function() {
    pendingTimer = null;
    console.log('RESOLVED FILES');
    console.log(resolveFile('test-app/test/main.js'));
  }, 500);
};


chokidar.watch(WATCH, {persistent: true}).add('test-app/test')
.on('change', function(path) {
  console.log('change', path);
  checkFile(path).then(function() {
    scheduleResolving();
    // console.log('RESOLVED FILES');
    // console.log(resolveFile('test-app/test/main.js'));
  }, function(e) {
    console.error(e);
    console.error(e.stack);
  });
})
.on('add', function(path) {
  console.log('add', path);
  checkFile(path).then(function() {
    scheduleResolving();
    // console.log('RESOLVED FILES');
    // console.log(resolveFile('test-app/test/main.js'));
  }, function(e) {
    console.error(e);
    console.error(e.stack);
  });
});

