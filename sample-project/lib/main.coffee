sys = require 'sys'
dlog = require('debug')('sample-project:main')
require('./includes/jquery')


main = () ->
  $(document).ready () ->
    load()


load = () ->
  $src = $('body').find('[data-src]')
  viewname = $src.data('view')

  if viewname
    dlog "loading '#{viewname}' with data url '#{$src.data('src')}'"
    require(viewname).load($src.data('src'))


module.exports.main = main
module.exports.load = load
