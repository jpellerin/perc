.. _configuration:

=============
Configuration
=============

perc keeps its configuration in your project's ``package.json``, under
they key ``perc``. The default configuration from the default skeleton
is:

.. code :: json

    {
      "name": "// etc.. ",
      "perc": {
        "build": {
          "sources": "lib",
          "sourcePattern": "**/*.coffee",
          "output": "static/app.js"
        },
        "check": {
          "dir": "sanity",
          "test": "test.html",
          "//moreTests": ["test.js"]
        },
        "test": {
          "cases": "spec/**/*.coffee"
        }
      }
    }

As you can see, each of the top-level keys in the configuration
corresponds to a perc command.

.. note ::

   Except where noted, all paths in perc's config are relative to the
   directory containing ``package.json``.

build
-----

The build section may be a simple map, in which case only one output
file is generated. It may also be a list of maps, in which case each
entry in the list corresponds with an output file, for example:

.. code :: json

    "build": [
        {
            "sources": "lib/app",
            "sourcePattern": "**/*.coffee",
            "output": "../static/js/app.js"
        },
        {
            "sources": "lib/help",
            "sourcePattern": "**/*.coffee",
            "output": "../static/js/helper.js",
            "entry": "lib/help/entry.js"
        }],

In either case, the entries in the build map ae the same:

.. describe :: sources

   The application's source directory. Default: ``lib``

.. describe :: sourcePattern

   The glob pattern used to match source files that you want to include in
   the build. This pattern is applied to files in the sources dir to select
   files directly included in the build. Default: ``**/*.coffee``

.. describe :: output

   The build output file. Default: ``static/app.js``

.. _check-config:

check
-----

.. describe :: dir

   The directory in which to place sanity check files. Default: ``sanity``.

.. describe :: test

   The html test file that will be used (with 
   `mocha_phantomjs <https://github.com/metaskills/mocha-phantomjs>`_) to sanity
   check the build. Default: ``test.html``.

   .. note ::

      This file is regenerated with each check and should not be edited
      by hand.

.. describe :: moreTests

   A list of additional test scripts to include in the sanity test file.
   Theses paths should be relative to the ``check.dir`` directory, not
   package root. Each file should be a *javascript* test written with
   `mocha <http://visionmedia.github.com/mocha/>`_ and 
   `chai <http://chaijs.com>`_.

The check command also supports some keys not in the default config:

.. describe :: runner

   Set the sanity check test runner. You can use this if
   mocha-phantomjs is not on your path, or if you want to use an
   entirely different sanity check test runner. The default is
   ``mocha-phantomjs``

.. describe :: runnerOpts

   Options to pass through to the sanity check test runner. Use this
   to set the mocha reporter, for instance.

.. describe :: template

   Path (relative to package root) to an
   `eco template <https://github.com/sstephenson/eco>`_ that will
   be used to generate the sanity test html file.

test
----

.. _cases:

.. describe :: cases

   The glob used (relative to package root) to find test cases.
   Default: ``spec/**/*.coffee``

The test command supports several additional config keys, which are
not set in the default configuration. All of these may also be set
with command-line options -- the command line options will override
the configuration value.

.. describe :: types

   The comma-separated list of types of tests to load. The specified
   types are used to match file sub-extensions to select
   tests. Default: ``spec,unit,functional``

.. describe :: reporter

   The mocha reporter to use. Default: ``spec``

.. describe :: timeout

   The mocha test timeout. Default: ``6000`` (6 seconds)

.. describe :: ui

   The mocha test-writing ui. Default: ``bdd``

.. describe :: coverageFile

   The file (relative to package root) where the coverage html report
   will be written in test coverage mode.

watch
-----

In some cases (especially applications with multiple build files), the
default ``watch`` command configuration may miss some library
files. For those cases, you can configure a list of additional
directories to watch:

.. code :: json

  "watch": ["common/lib"]

Changes to source files in those directories will trigger a rebuild.
