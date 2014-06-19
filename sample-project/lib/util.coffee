ko = require('./includes/knockout')

fromid = (data) ->
  if data?
    ko.utils.unwrapObservable(data.id)


exports.fromid = fromid
