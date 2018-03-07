// Generated by CoffeeScript 1.6.3
(function() {
  var builds, chokidar, command, dlog, minimatch, path, print, proc, shell, sty;

  path = require('path');

  proc = require('child_process');

  print = require('util').print;

  chokidar = require('chokidar');

  minimatch = require('minimatch');

  shell = require('shelljs');

  sty = require('sty');

  dlog = require('debug')('perc:watch');

  builds = require('../util').builds;

  module.exports = command = {
    help: "Watch for changes and test/build when they happen",
    init: function(command, config) {
      command.option('-T, --no-test', 'Do not run tests when application or test files change');
      command.option('-B, --no-build', 'Do not build when application files change');
      return command.option('-C, --no-check', 'Do not run check after building');
    },
    run: function(command, config, args) {
      var build, cmds, paths, pth, relpath, watcher, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      if (!command.test && !command.build && !command.check) {
        console.error("You really don't want me to do anything?");
        command.outputHelp();
        process.exit;
      }
      console.log("Watching:");
      this.config = config;
      paths = [];
      _ref = builds(config);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        build = _ref[_i];
        paths.push(path.resolve(build.sources));
        console.log("   " + (sty.b(build.sources)) + " (sources)");
      }
      if (config.watch != null) {
        _ref1 = config.watch;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          pth = _ref1[_j];
          paths.push(path.resolve(pth));
          console.log("    " + (sty.b(pth)) + " (sources)");
        }
      }
      if (command.test) {
        relpath = config.test.cases.split('/')[0];
        console.log("   " + (sty.b(relpath)) + " (tests)");
        paths.push(path.resolve(relpath));
      }
      if (command.check) {
        command.build = true;
      }
      watcher = chokidar.watch(paths, {
        persistent: true,
        ignoreInitial: true
      });
      cmds = {
        test: false,
        build: false,
        check: false
      };
      watcher.on('all', function(event, filename) {
        dlog("Ping! " + filename);
        console.log("" + (sty.b(event)) + " " + (path.relative(_this.config.root, filename)));
        if (_this.isSource(filename)) {
          if (command.test) {
            cmds.test = true;
          }
          if (command.build) {
            cmds.build = true;
          }
          if (command.check) {
            cmds.check = true;
          }
        } else if (command.test && _this.isTest(filename)) {
          cmds.test = true;
        }
        return _this.runExt(cmds);
      });
      return watcher.on('error', function(error) {
        return dlog("On no: " + error);
      });
    },
    isSource: function(path) {
      var build, _i, _len, _ref;
      _ref = builds(this.config);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        build = _ref[_i];
        if (minimatch(path, "**/" + build.sources + "/" + build.sourcePattern)) {
          return true;
        }
      }
      return false;
    },
    isTest: function(path) {
      return minimatch(path, "**/" + this.config.test.cases);
    },
    runExt: function(commands) {
      var code, output, _i, _len, _ref, _ref1, _results;
      _ref = ['test', 'build', 'check'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        command = _ref[_i];
        if (!commands[command]) {
          continue;
        }
        _ref1 = shell.exec("perc " + ([command, '-c', this.config.configPath].join(' ')), {
          silent: true
        }), code = _ref1.code, output = _ref1.output;
        if (code === 0) {
          console.log(sty.parse("  <b><green>✓</green> perc " + command + " <green>ok</green></b>"));
          _results.push(commands[command] = false);
        } else {
          console.log(sty.parse("  <red><b>✖ perc " + command + " failed!</b></red>"));
          console.log(output);
          console.log(Array(60).join('-'));
          console.log;
          break;
        }
      }
      return _results;
    }
  };

}).call(this);