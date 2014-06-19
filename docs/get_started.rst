===========
Get Started
===========

Install perc with npm
---------------------

To use perc you must first install it. The easy way to do that is:

.. code ::

   $ npm install -g git://github.com/jpellerin/perc

You may need ``sudo`` with that command, if you haven't configured
your "global" npm install space to be somewhere you can normally write
to. (`You should do that <https://npmjs.org/doc/config.html>`_,
though, if you haven't.)

If perc is properly installed and on your PATH after that,

.. code ::

   $ perc -V

should show you perc's current version, and

.. code ::

   $ perc -h

should show you some basic usage information.

Now that perc is working, it's time to percolate a project.

Percolate a new or existing project
-----------------------------------

You can use perc to start an entirely new application, or as the basis
for refactoring or retooling an existing application. In either case,
you're probably better off starting with a new, empty directory. For
the sake of not saying 'path/to/your/directory' everywhere, these
examples will call that directory 'frontend'.

Fill the empty directory with:

.. code ::

   $ perc init frontend

That should have copied the default perc project skeleton into the
frontend directory, which should now look like this:

.. code ::

   $ tree frontend/
   frontend/
   ├── index.js
   ├── lib
   │   └── example.coffee
   ├── Makefile
   ├── package.json
   ├── sanity
   │   ├── chai.js
   │   ├── mocha.css
   │   └── mocha.js
   ├── spec
   │   ├── example.spec.coffee
   └── tasks
       └─ perc.mk

You can find detailed information about each of those files
:ref:`here <init-command>`.

Go to the directory you just created.

Before running any other perc commands, you'll need to update
``package.json`` to have a sensible ``name`` and valid ``version``. Then run::

  $ npm install

To install your package dependencies. 

Now you can run :ref:`perc test <test-command>` to run tests,
:ref:`perc build <build-command>` to build your application, and
:ref:`perc check <check-command>` to sanity check the build.

Write code and tests
--------------------

The default project skeleton includes a sample module and sample spec
file to get you started. As you can see, neither one is very complex:

Module
~~~~~~

.. literalinclude :: ../skeleton/lib/example.coffee
   :language: coffeescript
   :linenos:

Spec
~~~~

.. literalinclude :: ../skeleton/spec/example.spec.coffee
   :language: coffeescript
   :linenos:


But they should give you an idea of how things work.
