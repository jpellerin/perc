.. Perc documentation master file, created by
   sphinx-quickstart on Wed Feb 20 17:09:27 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Perc's documentation!
================================

``perc`` is a coffeescript application development tool. Its goal is
to make developing large, modular browser applications in coffeescript
as painless as possible. It makes several assumptions and has several
opinions:

* application code and tests are written in coffeescript
* application code is organized into commonjs modules
* target build is a single, monolithic javascript file
  that includes all application modules and all modules
  they ``require``
* `mocha <http://visionmedia.github.com/mocha/>`_ is used for unit
  tests, which are run under nodejs, optionally using
  `jsdom <https://github.com/tmpvar/jsdom>`_
* build sanity check also uses mocha, but runs under
  `phantomjs <http://phantomjs.org/>`_

Contents:

.. toctree::
   :maxdepth: 2

   get_started
   configuration
   workflow
   init
   test
   build
   check
   watch
   custom_commands
   changelog



Indices and tables
==================

* :ref:`genindex`
* :ref:`search`

