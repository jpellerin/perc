perc
====

`perc` is a coffeescript application development tool. Its goal is to
make developing large, modular browser applications in coffeescript as
easy and painless as possible. It makes several assumptions and has
several opinions:

* application code and tests are written in coffeescript
* application code is organized into commonjs modules
* target build is a single, monolithic javascript file
  that includes all application modules and all modules
  they `require`
* [mocha](http://visionmedia.github.com/mocha/) is used for unit
  tests, which are run under nodejs, optionally using
  [jsdom](https://github.com/tmpvar/jsdom)
* build sanity check also uses mocha, but runs under
  [phantomjs](http://phantomjs.org/)


Get started
===========

Install
-------

```
npm install -g git://github.com/jpellerin/perc
```

Copy project skeleton
---------------------

The command `perc init` will copy a project skeleton -- either the
default, or any git repo -- into the working directory or a directory
you specify. It will only write files that don't already exist.

So, run `perc init` and then open up and customize the `package.json`
file it generated.

Once you've at least set a name and valid version (say, '1.0.0') in
`package.json`, run `npm install` to install common development
dependencies. Then you can run `perc` commands, either via the `perc`
script, or the `Makefile` that the skeleton generated (if you used the
default).

Here are some next steps:

* Find the example module in `lib` and a test module for it in
  `spec`.

* Run `perc test` (or `make test`) to run the tests.

* Run `perc build` or `make build` to build the output file
  (`static/app.js` unless you've customized it in `config.coffee`).

* Run `perc check` or `make check` to run sanity tests for the
  output file. Note that you need `phantomjs` installed to
  run the sanity tests.


Configuration
==============

> **NOTE** This is a change in version 0.2. In version 0.1,
> configuration was kept in a separate config file.

`perc` gets its configuration from the `perc` section in your
project's `package.json`. The default configuration values
from the skeleton are:

```json
{
    "perc": {
        "build": {
            "sources": "lib",
            "sourcePattern": "**/*.coffee",
            "output": "static/app.js"
        },
        "check": {
            "dir": "sanity",
            "test": "test.html"
             "//moreTests": ["test.js"]
        },
        "test": {
            "cases": "spec/**/*.coffee"
        }
    }
}
```

This means:

* Application code is in `lib/` and its subdirectories
* Unit tests are in `spec/`
* The output file for builds is `sanity/app.js`
* The automatically generated sanity test html file is `sanity/test.html`
* The sanity test will include only the generated tests, no custom
  tests -- `moreTests` is commented out (sort of... as well as you can 
  comment out a json key).


Workflow
========

`perc` encourages a TDDish workflow in which unit tests are written, if not
first, then often, and run frequently.


Write tests
-----------

Write tests using mocha's BDD style, give them the exension
`.spec.coffee`, and put them into the `spec/` directory. Run them with
`perc test` or `make test`.

Test coverage is available by adding the `-C` flag to `perc test` (or
call `make cover`). Coverage is output to `coverage.html`. It applies
to the coffescript sources, not the generated javascript.


Write application modules
-------------------------

Write application modules in coffeescript and put them under
`lib/`. You can use nodejs modules supported by
[browserify](http://browserify.org/) -- `npm install --save` them to
ensure your `package.json` stays up to date.

"Includes"
----------

If you want to use other, non-modular javascript files, put them in a
different directory, either under `lib/` or elsewhere. Then, `require`
them using a relative path as if they were commonjs modules. As long
as they operate on `window` or have a valid commonjs wrapper, they
should work fine. The ones without a wrapper, of course, won't export
anything, so whatever you want from them you'll have to pull out of
`global.window`. For instance, here's now the sample project uses
jquery, which it has placed under `lib/includes/`:

```coffeescript
require('../includes/jquery')

main = () ->
  $(document).ready () ->
    load()
```

In some cases you may need to update an include's commonjs wrapper, if
it has dependencies and lists them as global.


Build the application
---------------------

`perc build` will compile all of your coffeescript sources into
javascript and combine them into one monolithic module, which will be
saved to the path set by `config.build.output` -- `static/app.js` by
default. The real work is done by
[browserify](http://browserify.org/), so `perc` supports all of the
node modules that browserify does. You can also build a minimized
version.

The build application puts only the `require` function into the global
namespace. You use that to load application code. Here's how the
sample project does it:

```html
<script src="/static/app.js"></script>
<script>
  require('./lib/main').main()
</script>
```

Check the build
---------------

`perc check` will generate a sanity test file that checks that the
built application can load and that each of your application modules
can be `required`. If you want to test more than that, you can add
test modules to the sanity directory, and put them in your config
file's `config.check.moreTests` list.

The test file is set up to load
[mocha](http://visionmedia.github.com/mocha/),
[chai](http://chaijs.com) for use in writing additional tests. Note
that these tests will *not* be compiled from coffeescript
automatically. If you want to write sanity tests in coffeescript, you
must set up a build process for them.

You can also load the sanity test file in any browser.

Automate it
-----------

`perc watch` will watch your `lib/` and `spec/` directories and run
`perc test` (and optionally `perc build` and `perc check`) whenever it
detects a changed file.

Usage
=====

```
Usage: perc [options] command <command arguments...> <command options...>

For help on individual commands, enter perc command --help

Commands:

  help                   Print usage information
  build [options]        Build monolithic app.js in public directory
  check [options]        Run sanity tests on monolithic app.js file
  init [options]         Initialize a project from a skeleton
  test [options]         Run unit tests
  watch [options]        Watch for changes and test/build when they happen
  *                      Custom commmand modules are supported

Options:

  -h, --help               output usage information
  -V, --version            output the version number
  -c, --config [FILE]      Config file
  -s, --section [SECTION]  perc config key in config file
  -v, --verbose            Be more verbose
```

build
-----

```
Usage: build [options]

Build monolithic app.js in public directory

Options:

  -h, --help      output usage information
  -o, --optimize  Uglify/minify app.js
```

check
-----

> **NOTE**: mocha-phantomjs opts not working yet

```
Usage: check [options]

Run sanity tests on monolithic app.js file

Options:

  -h, --help                           output usage information
  -M, --mocha-phatomjs-opts [OPTIONS]  Set options for mocha-phantomjs

```

init
----

> **NOTE** skeletons from urls/git repos not working yet

```
Usage: init <path> [options]

Initialize a project from a skeleton

Options:

  -h, --help                     output usage information
  -S, --skeleton [SKELETON]      Skeleton path or url
  --set [NAME:VALUE,NAME:VALUE]  Set project package config variable
```

test
----

```
Usage: test <modules> [options]

Run unit tests

Options:

  -h, --help                    output usage information
  -S, --types [TYPES]           Set types of test to load
  -C, --cover                   Output coverage report
  -G, --grep [PATTERN]          Only run tests matching pattern
  -R, --reporter [REPORTER]     Set the mocha reporter
  -U, --ui [MOCHA_UI]           Set mocha ui (default: bdd)
  -T, --timeout [TEST_TIMEOUT]  Set test timeout
  --no-initdom                  Do not set up jsdom "window" before tests
  --no-ignoreleaks              Do not ignore leaks of globals

```

watch
-----

Watch for changes to lib or test files, run tests and/or build and check
when they happen.

```
Usage: watch [options]

Options:

  -h, --help      output usage information
  -T, --no-test   Do not run tests when project or test files change
  -B, --no-build  Do not build when project files change
  -C, --no-check  Do not run check after building
```

More Things!
============

Sample application
------------------

The sample application in `sample-project/` is a simple Flask app that
demonstrates how to integrate things like jquery, knockoutjs and
bootstrap, and test ajax calls and generally be cool.

Custom commands
---------------

Any module that exports a function can be a `perc` command. In theory,
at least. Custom commands may be local modules, local modules prefixed
with `perc-` or packages installed into `node_modules`. They should
generally follow the form:

```coffeescript
module.exports = (program, config, args...) ->
  # do something useful
  # exit with a non-zero exit code if something goes wrong

```

Emacs support
-------------

In the `extra` directory you'll find an elisp module (`perc.el`) and a
usage suggestion (`dot.emacs`). Put the module into `~/.emacs.d` and
the contents of `dot.emacs` into `~/.emacs` (or `~/.emacs.d/init.el`)
-- and adjust the perc command variable if needed -- and you'll be
able to run individual test modules from within emacs with `C-cM`, and
run the test module associated with an application module (either by
name or by setting the `spec` file variable) with `C-cs`.

Similar projects
================

[brunch](http://brunch.io) and [yeoman]() are good alternatives to `perc`.
