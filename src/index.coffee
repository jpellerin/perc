dlog = require('debug')('perc')

commands = require './commands'
cli = require './cli'


exports.run = ->
  dlog 'run: ', process.argv[2...]
  cli.run process.argv[2...], commands
