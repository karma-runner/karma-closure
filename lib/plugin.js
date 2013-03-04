// TODO(vojta): cache resolved
var initClosureDependencyResolver = function(emitter, fileList, resolver, iit, files) {
  var onlyPath = function(file) {
    return file.originalPath;
  };

  var createPattern = function(path) {
    return {pattern: path, included: true, served: true, watched: false};
  };

  files.unshift(createPattern(__dirname + '/no_deps_bullshit.js'));

  // whenever file list changes, resolve the deps - update files.included
  emitter.on('file_list_modified', function(promise) {
    promise.then(function(files) {
      var includedFiles = files.included;

      if (iit.isInclusive()) {
        includedFiles = includedFiles.filter(function(file) {
          // TODO(vojta): this is hacky, add some labels/flags to files
          // we need to distinquish test files, as iit/ddescribe should only filter those
          if (file.originalPath.indexOf('/test-app/test/') === -1) {
            return true;
          }

          return iit.filter(file.originalPath);
        });
      }

      var resolvedPaths = resolver.resolveFiles(includedFiles.map(onlyPath));
      var servedFiles = files.served;

      // TODO(vojta): change files.served to be a map, rather than an array
      files.included = resolvedPaths.map(function(filepath) {
        for (var i = 0, length = servedFiles.length; i < length; i++) {
          if (servedFiles[i].originalPath === filepath) {
            return servedFiles[i];
          }
        }

        console.error('NOT SERVED FILE', filepath);
        var externalFile = {
          path: filepath,
          originalPath: filepath,
          contentPath: filepath,
          isUrl: false,
          // TODO(vojta): cache mtime and restat when deps.js changes ?
          // TODO(votja): use the last synced CL number in google3 ?
          mtime: new Date()
        };

        files.served.push(externalFile);
        return externalFile;
      });
    });
  });

  // monkey-patch fileList to get notified when file is removed
  var originalRemoveFile = fileList.removeFile;
  fileList.removeFile = function(filepath, done) {
    resolver.removeFile(filepath);
    iit.removeFile(filepath);

    return originalRemoveFile.call(fileList, filepath, done);
  };

  return resolver;
};

initClosureDependencyResolver.$inject = ['emitter', 'fileList', 'x:resolver', 'x:iit-filter', 'config.files'];


var createPreprocesor = function(resolver) {
  return function(content, file, done) {
    resolver.updateFile(file.originalPath, content);
    done(content);
  };
};

createPreprocesor.$inject = ['x:resolver'];


var createDepsPreprocesor = function(resolver) {
  return function(content, file, done) {
    resolver.loadExternalDeps(file.originalPath, content);
    done(content);
  };
};

createDepsPreprocesor.$inject = ['x:resolver'];


var createIitPreprocesor = function(iit) {
  return function(content, file, done) {
    iit.updateFile(file.originalPath, content);
    done(content);
  };
};

createIitPreprocesor.$inject = ['x:iit-filter'];

// PUBLISH DI MODULE
module.exports = {
  'framework:closure': ['factory', initClosureDependencyResolver],
  'preprocessor:closure': ['factory', createPreprocesor],
  'preprocessor:closure-deps': ['factory', createDepsPreprocesor],
  'preprocessor:closure-iit': ['factory', createIitPreprocesor],

  // TODO(vojta): these should be internal
  'x:resolver': ['type', require('./resolver')],
  'x:iit-filter': ['type', require('./iit')]
};
