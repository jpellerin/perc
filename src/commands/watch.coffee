path = require 'path'
proc = require 'child_process'
{print} = require 'util'

chokidar = require 'chokidar'
minimatch = require 'minimatch'
shell = require 'shelljs'
sty = require 'sty'
dlog = require('debug')('perc:watch')

{builds} = require '../util'

module.exports = command =
  help: "Watch for changes and test/build when they happen"
  init: (command, config) ->
    command.option '-T, --no-test',
      'Do not run tests when application or test files change'
    command.option '-B, --no-build',
      'Do not build when application files change'
    command.option '-C, --no-check', 'Do not run check after building'

  run: (command, config, args) ->
    if not command.test and not command.build and not command.check
      console.error "You really don't want me to do anything?"
      command.outputHelp()
      process.exit

    console.log "Watching:" 

    @config = config
    paths = []
    for build in builds config
      paths.push path.resolve(build.sources)
      console.log "   #{sty.b build.sources} (sources)"

    if config.watch?
      for pth in config.watch
        paths.push path.resolve pth
        console.log "    #{sty.b pth} (sources)"

    if command.test
      relpath = config.test.cases.split('/')[0]
      console.log "   #{sty.b relpath} (tests)"
      paths.push path.resolve(relpath)
    if command.check
      command.build = true

    watcher = chokidar.watch paths,
      persistent: true
      ignoreInitial: true

    cmds =
      test: false
      build: false
      check: false
    watcher.on 'all', (event, filename) =>
      dlog "Ping! #{filename}"
      console.log "#{sty.b event} #{path.relative @config.root, filename}"
      if @isSource filename
        if command.test
          cmds.test = true
        if command.build
          cmds.build = true
        if command.check
          cmds.check = true
      else if command.test and @isTest filename
        cmds.test = true
      @runExt cmds

    watcher.on 'error', (error) ->
      dlog "On no: #{error}"

  isSource: (path) ->
    for build in builds @config
      if minimatch path, "**/#{build.sources}/#{build.sourcePattern}"
        return true
    return false

  isTest: (path) ->
    minimatch path, "**/#{@config.test.cases}"

  runExt: (commands) ->
    for command in ['test', 'build', 'check']
      if not commands[command]
        continue
      {code, output} = shell.exec "perc #{[command, '-c', @config.configPath].join(' ')}", silent: true
      if code is 0
        console.log sty.parse "  <b><green>✓</green> perc #{command} <green>ok</green></b>"
        commands[command] = false
      else
        console.log sty.parse "  <red><b>✖ perc #{command} failed!</b></red>"
        console.log output
        console.log Array(60).join('-')
        console.log
        break

