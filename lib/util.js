// Generated by CoffeeScript 1.6.3
(function() {
  var glob, modname, path, wrench;

  path = require('path');

  glob = require('glob');

  wrench = require('wrench');

  exports.find = function(mod) {
    return path.dirname(require.resolve(mod));
  };

  exports.sources = function(build) {
    var pat, sf, _i, _len, _ref, _results;
    pat = path.join(build.sources, build.sourcePattern);
    _ref = glob.sync(pat);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sf = _ref[_i];
      _results.push(modname(build, sf));
    }
    return _results;
  };

  exports.builds = function(config) {
    var builds;
    builds = config.build;
    if (!(builds instanceof Array)) {
      builds = [builds];
    }
    return builds;
  };

  exports.mkdirp = function(dir, mode) {
    if (mode == null) {
      mode = 0x1ff;
    }
    return wrench.mkdirSyncRecursive(dir, mode);
  };

  modname = function(build, sourcefile) {
    var relFile;
    relFile = path.relative(build.sources, sourcefile);
    return relFile.substr(0, relFile.lastIndexOf('.'));
  };

}).call(this);