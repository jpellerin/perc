===============
Custom commands
===============

perc can run custom commands. If the command specified on the command
line is not a built in, then perc will look for a custom command
module with a matching name.

A custom command module 's exports must be a function that takes the arguments
`program` and `config` and returns an exit code. perc will look for the module
in the current working directory, then the module prefixed with `perc-`,
and then look for both of those variants in the node/npm load path.

Here's an example of a simple custom command that just echoes its
arguments, from the sample project include with perc's source:

.. literalinclude :: ../sample-project/perc-echo.coffee
  :language: coffeescript
