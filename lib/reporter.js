/*

copy, paste & edit from mocha. no other way to override correctly
since the reporter itself uses console.log for output.

*/

var Base = require('mocha/lib/reporters/base'),
    cursor = Base.cursor,
    color = Base.color;


/**
 * Module dependencies.
 */

var Base = require('mocha/lib/reporters/base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `Spec`.
 */

exports = module.exports = CaptSpec;

/**
 * Initialize a new `Spec` test reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function CaptSpec(runner) {
    Base.call(this, runner);

    var self = this
    , stats = this.stats
    , indents = 0
    , n = 0
    , _log = console.log;

    function indent() {
        return Array(indents).join('  ')
    }

    function buffer() {
        var messages = [];
        return {

            messages: function () {
                return messages;
            },

            empty: function() {
                return messages.length == 0;
            },

            push: function( msg ) {
                messages.push(this.format(msg));
            },

            format: function( obj ) {
                var pfx = "";
                if (typeof obj != "object") {
                    return pfx + obj;
                }

                try {
                    return pfx + JSON.stringify(obj);
                } catch (e) {
                    return pfx + obj;
                }
            }
        }
    }

    runner.on('start', function(){
        _log();
    });

    runner.on('suite', function(suite){
        ++indents;
        _log(color('suite', '%s%s'), indent(), suite.title);
    });

    runner.on('suite end', function(suite){
        --indents;
        if (1 == indents) _log();
    });

    runner.on('test', function(test){
        process.stdout.write(indent() + color('pass', '  ◦ ' + test.title + ': '));
        // capture console.log
        test.buffer = buffer();
        console.log = function() {
            test.buffer.push.apply(
                test.buffer, Array.prototype.slice.apply(arguments));
        }
    });

    runner.on('pending', function(test){
        var fmt = indent() + color('pending', '  - %s');
        _log(fmt, test.title);
    });

    runner.on('pass', function(test){
        console.log = _log;
        if (typeof test.buffer !== 'undefined') {
            delete test.buffer;
        }
        if ('fast' == test.speed) {
            var fmt = indent()
                + color('checkmark', '  ' + Base.symbols.ok)
                + color('pass', ' %s ');
            cursor.CR();
            _log(fmt, test.title);
        } else {
            var fmt = indent()
                + color('checkmark', '  ' + Base.symbols.ok)
                + color('pass', ' %s ')
                + color(test.speed, '(%dms)');
            cursor.CR();
            _log(fmt, test.title, test.duration);
        }
    });

    runner.on('fail', function(test, err){
        console.log = _log;
        cursor.CR();
        _log(indent() + color('fail', '  %d) %s'), ++n, test.title);
        // output captured log messages, if any
        if (typeof test.buffer !== 'undefined' &&
            !test.buffer.empty()) {
            cursor.CR();
            _log(indent(), '   ', '-- log messages --');
            for (var i=0,ln=test.buffer.messages().length; i<ln; i++) {
                _log(indent(), '   ', test.buffer.messages()[i]);
            }
        }

    });

    runner.on('end', self.epilogue.bind(self));
}

/**
 * Inherit from `Base.prototype`.
 */

CaptSpec.prototype.__proto__ = Base.prototype;
