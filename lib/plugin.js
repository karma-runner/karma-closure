var DependencyResolver = require('./resolver');

// TODO(vojta): cache resolved
// TODO(vojta): filter included files by iit/ddescribe

var initClosureDependencyResolver = function(emitter, fileList) {
  var resolver = new DependencyResolver();

  // whenever file list changes, resolve the deps - update files.included
  emitter.on('file_list_modified', function(promise) {
    promise.then(function(files) {
      var pathsToResolve = files.included.map(function(file) {
        return file.originalPath;
      });
      var resolvedPaths = resolver.resolveFiles(pathsToResolve);
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
    return originalRemoveFile.call(fileList, filepath, done);
  };

  return resolver;
};

initClosureDependencyResolver.$inject = ['emitter', 'fileList'];


var createPreprocesor = function(resolver) {
  return function(content, file, done) {
    resolver.updateFile(file.originalPath, content);
    done(content);
  };
};

createPreprocesor.$inject = ['framework:closure'];


var createDepsPreprocesor = function(resolver) {
  return function(content, file, done) {
    resolver.loadExternalDeps(file.originalPath, content);
    done(content);
  };
};

createDepsPreprocesor.$inject = ['framework:closure'];


// PUBLISH DI MODULE
module.exports = {
  'framework:closure': ['factory', initClosureDependencyResolver],
  'preprocessor:closure': ['factory', createPreprocesor],
  'preprocessor:closure-deps': ['factory', createDepsPreprocesor]
};
