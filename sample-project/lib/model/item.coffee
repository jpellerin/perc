dlog = require('debug')('sample-project:model:item')
ko = require '../includes/knockout'
ko.mapping = require '../includes/knockout.mapping'


class Item
  mapping: {}

  constructor: (data) ->
    dlog 'New item from', data
    ko.mapping.fromJS data, @mapping, this

  purple: () ->
    "purple"

exports.Item = Item
