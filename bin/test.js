#!/usr/bin/env node
process.env.NODE_ENV = 'test';

var cwd = process.cwd();

var fs = require('fs');
var path = require('path');
var Mocha = require('mocha');
var optimist = require('optimist');
var walk_dir = require('../lib/walk_dir');
var reporter = require('../lib/reporter');

// CoffeeScript support
require('coffee-script')

module.paths.push(cwd, path.join(cwd, 'node_modules'));

var argv = optimist
    .usage("Usage: $0 -s [settings] -t [types] --reporter [reporter] --timeout [timeout]")
    .default({types: 'spec,unit,functional', reporter: reporter, timeout: 6000, settings: 'settings'})
    .describe('settings', 'The settings module to load.')
    .describe('types', 'The types of tests to run, separated by commas. E.g., unit,functional,acceptance')
    .describe('reporter', 'The mocha test reporter to use.')
    .describe('timeout', 'The mocha timeout to use per test (ms).')
    .boolean('help')
    .alias('settings', 's')
    .alias('types', 'T')
    .alias('timeout', 't')
    .alias('reporter', 'R')
    .alias('help', 'h')
    .argv;

if (argv.help) {
    console.log('\n' + optimist.help());
    process.exit();
}

var requested_types = argv.types.split(',');
var types_to_use = [];
var defaults = {
    ignoreLeaks: true,
    initDOM: true,
    requirejs: null,
    tests: 'spec',
    validTestTypes: ['spec', 'unit', 'functional', 'acceptance', 'integration']
}
/*
try {
    var project  = require(argv.settings);
} catch (e) {
    console.error("Error loading settings file", argv.settings, e);
    process.exit(1);
}
*/

var settings = defaults;
var test_path = argv._[0] || settings.tests;
var test_modules = argv._.length > 1 ? argv._.slice(1) : null;

settings.validTestTypes.forEach(function (valid_test_type) {
    if (requested_types.indexOf(valid_test_type) !== -1) {
        types_to_use.push(valid_test_type);
    }
});
if (types_to_use.length === 0) {
    console.log('\n' + optimist.help());
    process.exit();
}


var mocha = new Mocha({timeout: argv.timeout,
                       reporter: argv.reporter,
                       ui: 'bdd',
                       ignoreLeaks: settings.ignoreLeaks});

function run(cb) {

    if (settings.requirejs) {
        requirejs.config(settings.requirejs);
    }

    var is_valid_file = function (file) {
        for (var i = 0; i < types_to_use.length; i++) {
            var test_type = types_to_use[i];
            if (file.indexOf(test_type + ".js") !== -1 ||
                file.indexOf(test_type + ".coffee") !== -1) {
                if (test_modules && test_modules.indexOf(path.basename(file)) === -1) {
                    return false;
                }
                if (file.indexOf('~') === -1) {
                    return true;
                }
            }
        }

        return false;
    };

    walk_dir.walk(test_path, is_valid_file, function (err, files) {
        if (err) { return cb(err); }

        files.forEach(function (file) {
            mocha.addFile(file);
        });

        if (settings.initDOM) {
            var jsdom = require('jsdom');
            global.window = jsdom.jsdom().createWindow('<html><body></body></html>');
            global.document = global.window.document;
            global.navigator = {
                userAgent: "nodejs",
                platform: "nodejs",
                product: "nodejs"
            }
        }

        cb();
    });
}

run(function (err) {
    /*
    */
    mocha.run(function (failures) {
        process.exit(failures);
    });
});
