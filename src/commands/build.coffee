fs = require 'fs'
path = require 'path'

builder = require 'browserify'
glob = require 'glob'
wrench = require 'wrench'

dlog = require('debug')('perc:build')

util = require('../util')


module.exports = command =
  help: "Build monolithic app.js in public directory"
  init: (command, config) ->
    command.option '-o, --optimize', 'Uglify/minify app.js', false
    command.usage "[options]\n\n  #{@help}"

  run: (command, config) ->
    dlog 'build!', command, config
    for build in util.builds config
      make build, command

make = (build, command) ->
  verbose = command.parent.verbose
  ignore = build.ignore or 'jsdom'
  b = builder(exports: 'require', ignore: ignore)

  if verbose
    console.log "Building source files in #{build.sources}"
  for modname in util.sources build
    dlog "require './#{modname}'"
    if verbose
      console.log " -> #{modname}"
    b.require "./#{modname}", dirname: build.sources

  # ensures that the relative package names in the
  # build file are always the same -- as if chrooted here
  b.require './index'

  if build.entry
    b.addEntry build.entry

  # output to config.build.output
  src = b.bundle()
  if not b.ok
    # FIXME actual error message?! b.on error maybe?
    console.error "Failed to build!"
    return

  util.mkdirp path.dirname(build.output)

  fs.writeFile build.output, src, (err) ->
    if err
      console.error "Failed to write output file: #{err}"
      process.exit 1
    console.log "Built #{build.output}"

    # minify if -o
    if command.optimize
      ugly = require 'uglify-js'
      min = ugly.minify(build.output)
      minfile = build.output.replace /\.js$/, '.min.js'

      fs.writeFile minfile, min.code, ->
       console.log "Minified to #{minfile}"
