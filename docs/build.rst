.. _build-command:

===================
Command: perc build
===================

Details
-------

The ``build`` command builds the output file(s). **This is the only point**
in the ``perc`` workflow where **compiled javascript is written to disk.**

What goes in the files
~~~~~~~~~~~~~~~~~~~~~~

Every module in the build's source dir that matches the build's
sourcePattern is fed into `browserify <http://browserify.org>`_. So,
all of those files, and **every module they require** are included in
the output file.

The compiled output file defines only one global: ``require``. Use
this to load your application entry points.

To run an entry point without needing to call ``require``, define an
entry file for the build. If the build defines an entry file, that
file is included as-is in the build, without being compiled. The file
is included directly so that it will run at load time, without needing
to ``require`` anything.


Using the output file: require from html
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For modules installed under **node_modules**, the require path in the
output file is the **same as everywhere else**. However, **this is not
true** for files in your source tree or modules that are **not**
located in node_modules at compilation time. For those modules, the
require path is a **pseudo absolute path** -- the "absolute" path from
the **root of your project** to the source file. So, if your source
dir is ``lib``, path that you would use to require ``lib/main.coffee``
**in an html file that loads your compiled application**, is
``/lib/main``.

Usage
-----

.. command-output :: perc build --help

Options
-------

.. option :: -o, --optimize

   Also produce a minified build. The minified build will be output in
   the same directory as the un-minified compiled application file,
   with the same name except for the addition of '.min' as a
   sub-extension. So, if the compiled output file is 'static/app.js', the
   minified file will be 'static/app.min.js'
