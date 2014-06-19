#
# derived in part from mocha's html-cov reporter
#
dlog = require('debug')('perc:coverage')
fs = require 'fs'
path = require 'path'
JSONCov = require 'mocha/lib/reporters/json-cov'

util = require './util'

makeReporter = (basereporter, coverageFile) ->
  Reporter = require "mocha/lib/reporters/#{basereporter}"
  addCoverage(Reporter, coverageFile)


addCoverage = (reporter, filename) ->
  (runner) ->
    # this initializes the real reporter
    self = new reporter(runner)

    jade = require 'jade'
    mdir = util.find 'mocha'
    template = "#{mdir}/lib/reporters/templates/coverage.jade"
    tmpl = jade.compile fs.readFileSync(template, 'utf8'),
      filename: template

    # the actual coverage collector
    JSONCov.call self, runner, false

    runner.on 'end', =>
      output = tmpl cov: self.cov, coverageClass: coverageClass
      fs.writeFileSync filename, output
      console.log "HTML coverage report written to #{filename}"


coverageClass = (n) ->
  if n >= 75
     'high'
  else if (n >= 50)
     'medium'
  else if (n >= 25)
     'low'
  else
    'terrible'


exports = module.exports = makeReporter
