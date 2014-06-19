dlog = require('debug')('sample-project:test')
assert = require 'assert'
sinon = require 'sinon'
view = require '../lib/view/main'

describe 'The main view', ->
  before ->
    require '../lib/includes/jquery'
    $ = global.$ = window.$

  beforeEach ->
    sinon.stub window.$, 'getJSON'

  afterEach ->
    window.$.getJSON.restore()

  it 'should load and map api data', ->
    window.$.getJSON.callsArgWith 1,
      name: 'A name'
      items: [
        id: 1
        name: 'An item name'
      ]
    view = view.load '*url*'
    assert.equal view.name(), 'A name'
    assert.equal view.items?()[0]?.name(), 'An item name'
