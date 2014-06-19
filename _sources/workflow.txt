=================
Working with perc
=================

perc encourages a TDDish workflow in which unit tests are written, if not
first, then often, and run frequently.

.. note ::

   Specific file paths, extensions, and so on mentioned below assume
   the default configuration. See :ref:`configuration` for details
   about which are configurable and how to configure them.

Write tests
-----------

Write tests using mocha's BDD style, give them the exension
``.spec.coffee``, and put them into the ``spec/`` directory. Run them with
:ref:`perc test <test-command>` or ``make test``.

Test coverage is available by adding the :option:`-C` flag to :ref:`perc
test <test-command>` (or call ``make cover``). Coverage is output to
``coverage.html``. It applies to the coffescript sources, not the
generated javascript.


Write application modules
-------------------------

Write application modules in coffeescript and put them under
``lib/``. In your application (and tests, for that matter), you can
use nodejs modules supported by `browserify <http://browserify.org/>`_
-- ``npm install --save`` them to ensure your ``package.json`` stays
up to date.

"Includes"
----------

If you want to use other, non-modular javascript files, put them in a
different directory, either under ``lib/`` or elsewhere. Then, ``require``
them using a relative path as if they were commonjs modules. As long
as they operate on ``window`` or have a valid commonjs wrapper, they
should work fine. The ones without a wrapper, of course, won't export
anything, so whatever you want from them you'll have to pull out of
``global.window``. For instance, here's now the sample project uses
jquery, which it has placed under ``lib/includes/``:

.. code :: coffeescript

   require('../includes/jquery')

   main = () ->
     $(document).ready () ->
       load()

In some cases you may need to update an include's commonjs wrapper, if
it has dependencies and lists them as global.


Build the application
---------------------

:ref:`perc build <build-command>` will compile all of your coffeescript sources into
javascript and combine them into one monolithic module, which will be
saved to the path set by ``config.build.output`` -- ``static/app.js`` by
default. The real work is done by
`browserify <http://browserify.org/>`_, so ``perc`` supports all of the
node modules that browserify does. You can also build a minimized
version.

The build application puts only the ``require`` function into the global
namespace. You use that to load application code. Here's how the
sample project does it:

.. code :: html

   <script src="/static/app.js"></script>
   <script>
     require('/lib/main').main()
   </script>

.. note ::

   Note the require path: ``/lib/main`` -- it is an absolute path,
   as if running chrooted into the package root. This is how to
   address modules at the top level, in an html page that
   pulls in the build application.


Check the build
---------------

:ref:`perc check <check-command>` will generate a sanity test file
that checks that the built application can load and that each of your
application modules can be ``required``. If you want to test more than
that, you can add test modules to the sanity directory, and put them
in your config file's ``config.check.moreTests`` list.

The test file is set up to load
`mocha <http://visionmedia.github.com/mocha/>`_,
`chai <http://chaijs.com>`_ for use in writing additional tests. Note
that these tests will *not* be compiled from coffeescript
automatically. If you want to write sanity tests in coffeescript, you
must set up a build process for them.

You can also load the sanity test file in any browser.

Automate it
-----------

:ref:`perc watch <watch-command>` will watch your ``lib/`` and
:ref:``spec/`` directories and run `perc test <test-command>` (and
:ref:optionally :ref:`perc build <build-command>` and :ref:`perc check
:ref:<check-command>`) whenever it detects a changed file.

For each change it sees, :ref:`perc watch <watch-command>` prints the
file name, then the results of running the specified commands. When
commands succeed, the output is just (for instance) "perc test
ok". When commands fail, the stdout and stderr output from the command
is printed, after a failure notice.

:ref:`perc watch <watch-command>` runs continuously, so you'll
probably want to run it in a dedicated shell.
