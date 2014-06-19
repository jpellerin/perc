module.exports = (program, config, args...) ->
  console.log "The custom command was called"
  console.log "Program:"
  console.dir program
  console.log "Config:"
  console.dir config
  if args
    console.log "Other arguments:"
    console.log args

  0
