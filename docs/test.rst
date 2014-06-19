.. _test-command:

==================
Command: perc test
==================

.. program :: perc test

Details
-------

The ``test`` command compiles and runs tests that match the
:ref:`configured test case selector <cases>` (as well as any filtering
options set on the command line). There is an option to activate code
coverage reporting for coffeescript source files.

One important thing to note about the test command: **it does not
write compiled javascript files to disk.** All compilation occurs
inline.

Caveats and gotchas
~~~~~~~~~~~~~~~~~~~

* Stack traces printed with test failures and errors have inaccurate
  line numbers: they refer to the line in the compiled javascript
  module, not in the coffeescript source.

* Remember to put '.spec' or '.unit' in your test file names. This is
  easy to forget and leads to confusing non-loading of tests. See
  :option:`--types <perc test -S>` for details.

IDE integration
~~~~~~~~~~~~~~~

perc's source distribution includes an emacs module in the ``extra/``
directory that you can use to run tests inside of emacs. Copy
``extra/perc.el`` into your load path, and see the file ``dot.emacs``
(also in ``extra/``) for an example configuration.


Usage
-----

.. command-output :: perc test --help

Options
-------

.. option :: -S [TYPES], --types [TYPES]

   Set the types of tests to run. This must be a comma-separated list
   of test type names. A prospective test module must include one of
   these names as a sub-extension in order to match and be loaded. For
   instance if 'spec' is included in the list, the test module
   ``test.spec.coffee`` will load; but if the list were only
   'integration,functional`, that test module would *not* be loaded.

   The default value is "spec,unit,functional"

.. option :: -C, --cover

   Measure code coverage during testing. It is important to note
   that **coverage can only be measured for .coffee files**, because the
   instrumentation that allows coverage measurement takes place
   during coffeescript compilation.

   .. note ::

     This option can interact with the :option:`--reporter <perc test -R>`
     option, below. If you turn on code coverage but have
     selected a non-coverage reporter, the selected reporter will be
     wrapped by another reporter that outputs an html coverage
     file. If you do not want html coverage output, set
     :option:`--reporter <perc test -R>` to a reporter with
     "cov" in the name.

   Default: false

.. option :: -G [PATTERN], --grep [PATTERN]

   The grep option is passed through to mocha, where it will be used to filter
   test modules and cases. Only modules and cases that match the grep
   expression will be loaded.

   Default: None

.. option :: -R [REPORTER], --reporter [REPORTER]

   The mocha reporter. This option, like :option:`--grep <perc test -G>`
   and :option:`--ui <perc test -U>`, is passed directly to
   mocha.

   .. note ::

      This option can interact with the :option:`--cover <perc test -C>`
      option above, If you turn on code coverage but have
      selected a non-coverage reporter, the selected reporter will be
      wrapped by another reporter that outputs an html coverage
      file. If you do not want html coverage output, specify with
      "cov" in the name.

   Default: spec

.. option :: -U [UI], --ui [UI]

   This option, like :option:`--grep <perc test -G>` and
   :option:`--reporter <perc test -R>`, is passed through to
   mocha. Use it to set the test-writing ui that mocha makes
   available.

   Default: bdd

.. option :: -T [TEST_TIMEOUT], --timeout [TEST_TIMEOUT]

   Set the maximum time each individual test will be allowed to
   execute before failing, in milliseconds.

   Default: 6000

.. option :: --no-initdom

   Turn off jsdom initialization. By default, ``perc test`` mimics a
   browser environment by using jsdom to create a global ``window``
   and ``document``. If you don't want this to happen, or want to
   control it yourself, use this option to turn it off.

   Default: false

.. option :: --no-ignoreleaks

   Turn on mocha's global leak detection. Note that this option and
   :option:`--initdom <perc test --no-initdom>` are unlikely to work well
   together. It is also likely that, if you turn on mocha's global
   leak checking, you will not be able to use any non-npm modul in
   your application (or at least, not in any part of it with tests run
   by ``perc test``).

