#
# Custom knockoutjs bindings
#
ko = require './includes/knockout'

require './includes/jquery'
require './includes/bootstrap'


ko.bindingHandlers.tooltip =
  update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
    value = valueAccessor()
    rawValue = ko.utils.unwrapObservable value
    if rawValue
      $(element).tooltip title: rawValue, placement: 'left'
    else
      $(element).tooltip 'destroy'
