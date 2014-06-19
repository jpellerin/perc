// Generated by CoffeeScript 1.6.3
(function() {
  var builder, command, dlog, fs, glob, make, path, util, wrench;

  fs = require('fs');

  path = require('path');

  builder = require('browserify');

  glob = require('glob');

  wrench = require('wrench');

  dlog = require('debug')('perc:build');

  util = require('../util');

  module.exports = command = {
    help: "Build monolithic app.js in public directory",
    init: function(command, config) {
      command.option('-o, --optimize', 'Uglify/minify app.js', false);
      return command.usage("[options]\n\n  " + this.help);
    },
    run: function(command, config) {
      var build, _i, _len, _ref, _results;
      dlog('build!', command, config);
      _ref = util.builds(config);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        build = _ref[_i];
        _results.push(make(build, command));
      }
      return _results;
    }
  };

  make = function(build, command) {
    var b, ignore, modname, src, verbose, _i, _len, _ref;
    verbose = command.parent.verbose;
    ignore = build.ignore || 'jsdom';
    b = builder({
      exports: 'require',
      ignore: ignore
    });
    if (verbose) {
      console.log("Building source files in " + build.sources);
    }
    _ref = util.sources(build);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      modname = _ref[_i];
      dlog("require './" + modname + "'");
      if (verbose) {
        console.log(" -> " + modname);
      }
      b.require("./" + modname, {
        dirname: build.sources
      });
    }
    b.require('./index');
    if (build.entry) {
      b.addEntry(build.entry);
    }
    src = b.bundle();
    if (!b.ok) {
      console.error("Failed to build!");
      return;
    }
    util.mkdirp(path.dirname(build.output));
    return fs.writeFile(build.output, src, function(err) {
      var min, minfile, ugly;
      if (err) {
        console.error("Failed to write output file: " + err);
        process.exit(1);
      }
      console.log("Built " + build.output);
      if (command.optimize) {
        ugly = require('uglify-js');
        min = ugly.minify(build.output);
        minfile = build.output.replace(/\.js$/, '.min.js');
        return fs.writeFile(minfile, min.code, function() {
          return console.log("Minified to " + minfile);
        });
      }
    });
  };

}).call(this);