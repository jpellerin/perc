fs = require('fs')
path = require('path')

coffee = require 'coffee-script'

dlog = require('debug')('perc:test')
glob = require('glob')
Mocha = require('mocha')

module.exports = command =
  help: "Run unit tests"

  init: (command, config) ->
    command.option '-S, --types [TYPES]', 'Set types of test to load'
    command.option '-C, --cover', 'Output coverage report', false
    command.option '-G, --grep [PATTERN]', 'Only run tests matching pattern'
    command.option '-R, --reporter [REPORTER]', 'Set the mocha reporter', 'spec'
    command.option '-U, --ui [MOCHA_UI]', 'Set mocha ui (default: bdd)', 'bdd'
    command.option '-T, --timeout [TEST_TIMEOUT]', 'Set test timeout'
    command.option '--no-initdom', 'Do not set up jsdom "window" before tests'
    command.option '--no-ignoreleaks', 'Do not ignore leaks of globals'
    command.usage "<modules> [options]\n\n  #{@help}"

  run: (command, config, args) ->
    # combine command, config
    types = command.types or config.test.types or 'spec,unit,functional'
    reporter = command.reporter or config.test.reporter or 'spec'
    timeout = command.timeout or config.test.timeout or 6000
    modules = args[0...-1] if args.length > 1
    grep = command.grep or config.test.grep or null
    initdom = command.initdom
    ui = config.test.ui or command.ui
    ignoreLeaks = command.ignoreleaks
    cover = command.cover
    coverageFile = config.test.coverageFile or 'coverage.html'

    dlog 'test', modules

    if cover
      if not /cov/.test(reporter)
        helper = require '../coverage'
        reporter = helper(reporter, coverageFile)

    mopts =
      reporter: reporter
      ui: ui
      timeout: timeout
      ignoreLeaks: ignoreLeaks

    if grep
      mopts.grep = grep

    typere = new RegExp "\\.#{types.replace(',', '|')}\\."

    mocha = new Mocha(mopts)

    for specfile in glob.sync(config.test.cases)
      if not specfile.match typere
        dlog "${specfile} does not match types list, skipped"
        continue
      if not modules or modin(config, specfile, modules)
        mocha.addFile specfile
      else
        dlog "${specfile} not in module list, skipped"

    if initdom
      setupDOM()

    if cover
      setupCoverage config
    else
      require '../require-hook'

    mocha.run (failures) ->
      dlog "Mocha callback, failures #{failures}"
      process.exit failures


setupDOM = ->
  jsdom = require 'jsdom'
  global.window = jsdom.jsdom().createWindow('<html><body></body></html>')
  global.document = global.window.document
  global.navigator =
    userAgent: "nodejs"
    platform: "nodejs"
    product: "nodejs"


setupCoverage = (config) ->
  coverage = require 'coffee-coverage'
  minimatch = require 'minimatch'
  cover = new coverage.CoverageInstrumentor()

  require.extensions['.coffee'] = (module, filename) ->
    file = fs.readFileSync filename, 'utf8'
    opts =
      filename: filename

    if minimatch filename, "**/#{config.test.cases}"
      content = coffee.compile file, opts
      return module._compile content, filename

    result = cover.instrumentCoffee filename, file
    module._compile result.init + result.js, filename


# helpers
modin = (config, filename, modules) ->
  abs = path.resolve config.root, filename
  rel = path.relative config.root, abs
  noext =
    if rel.indexOf('.coffee') != -1 
      rel.substr 0, rel.indexOf('.coffee')
    else
      rel
  return rel in modules or noext in modules
