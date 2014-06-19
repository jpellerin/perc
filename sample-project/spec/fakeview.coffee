dlog = require('debug')('sample-project:test:fakeview')
dlog 'fakeview module executed'

loaded = null


load = (url) ->
  dlog "Hello #{url}"
  loaded = url


module.exports = exports =
  load: load
  loadedUrl: ->
    loaded
