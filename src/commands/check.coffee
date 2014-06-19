# use mocha-phantomjs to run the sanity test file
fs = require 'fs'
path = require 'path'
proc = require 'child_process'
print = require('util').print

dlog = require('debug')('perc:check')
eco = require 'eco'
glob = require 'glob'


util = require '../util'


module.exports = command =
  help: "Run sanity tests on monolithic app.js file"

  init: (command, config) ->
    command.usage "\n\n  #{@help}"

  run: (command, config) ->
    for build in util.builds config
      check build, config, command

check = (build, config, command) ->
    test_path = path.resolve(
      path.join(config.check.dir, config.check.test))
    app_js_path = path.resolve(build.output)
    template = __dirname + "/../../templates/sanity-test.html.eco"
    template = fs.readFileSync(config.check.template ? template, "utf-8")

    ctx =
      app_js: path.relative(
        path.resolve(config.check.dir), app_js_path)
      cases: "/#{build.sources}/#{mod}" for mod in util.sources(build)
      more_tests: config.check.moreTests

    dlog 'context', ctx

    util.mkdirp config.check.dir
    html = eco.render template, ctx

    fs.writeFileSync test_path, html

    # run mocha-phantomjs, pipe its output, and exit with its exit code
    mpj = config.check.runner ? 'mocha-phantomjs'
    opts = [test_path]
    if config.check.runnerOpts
      opts.push config.check.runnerOpts
    child = proc.spawn mpj, opts

    child.stdout.on 'data', (data) ->
      print data.toString()

    child.stderr.on 'data', (data) ->
      print data.toString()

    child.on 'exit', (code) ->
      if code == 8 and mpj == 'mocha-phantomjs'
        print "mocha-phantomjs returned an error. This probably means you don't have phantomjs installed. (run `npm install -g phantomjs`)\n"
      if code != 0
        process.exit code
