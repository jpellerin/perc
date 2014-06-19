path = require 'path'

glob = require 'glob'
wrench = require 'wrench'


exports.find = (mod) ->
  path.dirname require.resolve(mod)


exports.sources = (build) ->
  pat = path.join(build.sources, build.sourcePattern)
  modname(build, sf) for sf in glob.sync pat


exports.builds = (config) ->
  builds = config.build
  if not (builds instanceof Array)
    builds = [builds]
  builds


exports.mkdirp = (dir, mode=0o0777) ->
  wrench.mkdirSyncRecursive dir, mode


modname = (build, sourcefile) ->
  relFile = path.relative build.sources, sourcefile
  relFile.substr 0, relFile.lastIndexOf('.')


