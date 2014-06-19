path = require 'path'
fs = require 'fs'

extend = require 'extend'
dlog = require('debug')('perc:cli')

defaultConfig =
  build:
    sources: 'lib'
    sourcePattern: '**/*.coffee'
    output: 'static/app.js'
  check:
    dir: 'sanity'
    test: 'test.html'
  test:
    cases: 'spec/**/*.coffee'


exports.run = (argv, commands) ->
  dlog "run", argv, commands

  # base program
  #
  pkg = JSON.parse fs.readFileSync(__dirname + '/../package.json', 'utf8')
  program = require 'commander'
  program
    .usage('[options] command <command arguments...> <command options...>' +
      '\n\n  For help on individual commands, enter perc command --help')
    .version(pkg.version)
    .option('-c, --config [FILE]', 'Config file', 'package.json')
    .option('-s, --section [SECTION]', 'perc config key in config file', 'perc')
    .option('-v, --verbose', 'Be more verbose', false)

  program._name = 'perc'
  program.gotCommand = false

  program
    .command('help')
    .usage('')
    .description('Print usage information')
    .action () ->
      program.gotCommand = true
      program.help()

  # load config first, so commands can use it
  parsed = program.parseOptions(program.normalize process.argv[2...])
  config = loadConfig program.config, program.section

  runf = {}
  for name, mod of commands
    do (name, mod) ->
      cmd = program.command(mod.command ? name)
        .description(mod.help)
        .action (args...) ->
          dlog 'run command action', name
          program.gotCommand = true
          mod.run cmd, config, args
      mod.init cmd, config

  program
    .command('*')
    .description('Custom commmand modules are supported')
    .usage('A custom command module\'s exports must be a function that\n
           takes the arguments `program` and `config` and returns an exit code. \n
           perc will look for the module in the current working directory,\n
           then the module prefixed with `perc-`, and then look for both of\n
           those variants in the node/npm load path.')
    .action (name, program, args...) ->
      program.gotCommand = true
      process.exit customOrHelp(name, program, config, args...)

  # run! everything happens in the command callback
  opts = program.parseArgs parsed.args, parsed.unknown

  if not program.gotCommand
    dlog "Did not get a command"
    customOrHelp null, program, config


loadConfig = (config='package.json', section='perc') ->
  configPath = path.resolve config
  dlog configPath
  if fs.existsSync configPath
    try
      pkg = require configPath #
    catch e
      # the traceback from JSON.parse shows the bad line
      console.error "Error reading config file #{config}"
      JSON.parse fs.readFileSync(configPath, 'utf8')
  else
    pkg = {}
  dlog pkg
  config = defaultConfig
  extend true, config, pkg[section] or {}
  config.root = path.dirname configPath
  config.configPath = configPath
  dlog config
  config


customOrHelp = (name, program, config, args...) ->
  dlog "custom or help #{name}", program, args
  if name
    cwd = process.cwd()
    names = ["#{cwd}/#{name}", "#{cwd}/perc-#{name}", name, "perc-#{name}"]
    mod = safeRequire names
    if mod
      mod program, config, args...
    else
      console.error "Command module '#{name}' not found"
      console.error "Tried: #{names.join ', '}"
      program.outputHelp()
      process.exit 1
  else
    console.error "A command is required"
    program.outputHelp()
    process.exit 1


safeRequire = (names) ->
  for name in names
    mod = _safeRequire name
    dlog "safeRequire #{name}: #{mod}"
    if mod
      return mod
  return


_safeRequire = (name) ->
    try
      return require name
    catch e
      dlog "require #{name}: #{e}"
      if e.code is 'MODULE_NOT_FOUND'
        return null
      else
        throw e
  return null
