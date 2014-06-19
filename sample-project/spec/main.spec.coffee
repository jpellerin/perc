assert = require 'assert'
dlog = require('debug')('sample-project:test')

main = require '../lib/main'


describe 'The main module', ->
  before ->
    require '../lib/includes/jquery'
    $ = global.$ = window.$
    $('body').append($('<div id="view" data-view="../spec/fakeview"
                        data-src="*url*"></div>'))
    dlog "before html: '#{$('body').html()}'"

  it 'should load the specified view and data url', ->
    try
      fake = require('./fakeview')
      main.load()
      assert.equal(fake.loadedUrl(), '*url*')
    catch e
      dlog "error: #{e}"
      throw e

