.. _watch-command:

===================
Command: perc watch
===================

.. program :: perc watch

Details
-------

The ``watch`` command runs forever (in the foreground), waiting for
changes to files in your application's source and test
directories. When it sees changes to application files, it runs
:ref:`perc test <test-command>`, :ref:`perc build <build-command>`, and then
:ref:`perc check <check-command>`. When it sees changes to test files, it only runs
:ref:`perc test <test-command>`. If any command fails, further commands are *not*
run until the next change is detected (and the failing command
passes).

Usage
-----

.. command-output :: perc watch --help

Options
-------

.. option :: -T, --no-test

   Don't run ``perc test`` when application or test files change.

.. option :: -B, --no-build

   Don't run ``perc build`` when application files change.

.. option :: -C, --no-check

   Don't run ``perc check`` after building.
