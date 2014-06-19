.. _check-command:

===================
Command: perc check
===================

Details
-------

The ``check`` command uses an actual browser or browser-like
environment to load an html file that includes your compiled
application, as well as a series of tests that check that each library
module compiled into the application can be loaded with ``require``.

The defaults for how the ``check`` command works are:

* The browser-like test runner is `mocha-phantomjs <http://metaskills.net/mocha-phantomjs/>`_.
* The html page is build from the .eco template included with perc,
   which generates a test for each application module in the form:

  .. code :: javascript

      it('should include the module "/lib/main"', function() {
        require("/lib/main");
      });

The :ref:`configuration reference <check-config>` for the ``check``
command details how to change those defaults, as well as how to add
additional tests to the sanity check and pass options to the test
runner.

Usage
-----

.. command-output :: perc check --help
