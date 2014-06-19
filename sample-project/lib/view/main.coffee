# -*- spec: main_view.spec.coffee -*-
#
dlog = require('debug')('sample-project:view:main')
ko = require '../includes/knockout'
ko.mapping = require '../includes/knockout.mapping'

Item = require('../model/item').Item
util = require '../util'

require '../bindings'
require '../includes/jquery'

class ViewModel

  mapping:
    items:
      key: util.fromid,
      create: (options) ->
        new Item options.data, this

  constructor: (@url) ->
    dlog('viewmodel for', @url)
    @ready = ko.observable(false)
    $.getJSON @url, (data) =>
      @refresh data

  refresh: (data) ->
    dlog('refresh', @, data)
    ko.mapping.fromJS data, @mapping, this
    @ready(true)

load = (url) ->
  vm = new ViewModel(url)
  ko.applyBindings vm
  vm


module.exports.load = load
