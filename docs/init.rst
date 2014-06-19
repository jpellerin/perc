.. _init-command:

==================
Command: perc init
==================

.. program :: perc init


Details
-------

The ``init`` command copies the specified skeleton (or the default
perc skeleton, if none is specified) to the specified target directory
(or the current working directory, if no target is
specified). Typically, you will run this once, to begin a new project
or begin converting an existing project. If you need to run it more
than once, note that it will not overwrite existing files in the
target directory -- with one exception. If you use the :option:`perc
init --set` option, then ``package.json`` **will** be overwritten and
the specified values replaced.


Usage
-----

.. command-output :: perc init --help

Options
-------

.. option :: -S [SKELETON], --skeleton [SKELETON]

   Path on disk or url to the desired skeleton.

   The url may be an ``http`` url to a ``.tar.gz`` archive, or a
   ``git`` or ``http`` url pointing to a git repository.

   Examples::

     -S ~/skeleton
     -S /tmp/skel
     -S http://example.com/skel.tar.gz
     -S git://github.com/user/skellington.git

.. option :: --set [NAME:VALUE,NAME:VALUE]

   Set ``package.json`` variables. This must be a comma-separated list
   of name:value pairs. If you need to include spaces in a name or
   value, enclose the entire argument in quotes. **Dotted names are
   not supported** -- only top-level variables can be set using this
   shortcut.

   Examples::

     --set name:myproject,version:1.0.0

   .. warning ::

      When :option:`perc init --set` is used, ``package.json`` **will** be
      overwritten. Any values currently set for the specified
      variables will be replaced.

