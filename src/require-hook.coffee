#
# Installs .coffee require hook that produces source maps
# and attaches them to require.main._sourceMap
#
fs = require 'fs'
coffee = require 'coffee-script'
{prettyErrorMessage} = require 'coffee-script/lib/coffee-script/helpers'

if require.extensions
  require.extensions['.coffee'] = (module, filename) ->
    main = require.main
    #
    # this is from coffee-script.loadFile, modified to
    # add the sourceMap option
    #
    raw = fs.readFileSync filename, 'utf8'
    stripped = if raw.charCodeAt(0) is 0xFEFF then raw.substring 1 else raw
    options =
      filename: filename
      sourceMap: true
    try
      answer = coffee.compile(stripped, options)
    catch err
      useColors = process.stdout.isTTY and not process.env.NODE_DISABLE_COLORS
      message = prettyErrorMessage err, filename, stripped, useColors
      process.stderr.write message
      process.stderr.write '\n'
      process.exit 1
    do patchStackTrace
    mapped filename, answer.sourceMap
    module._compile answer.js, filename

#
# Below is all copied from coffee-script.coffee, which unforunately
# (as of 1.6.2) doesn't activate or expose it for inline compilation
#

# Based on [michaelficarra/CoffeeScriptRedux](http://goo.gl/ZTx1p)
# NodeJS / V8 have no support for transforming positions in stack traces using
# sourceMap, so we must monkey-patch Error to display CoffeeScript source
# positions.

patched = false
patchStackTrace = ->
  return if patched
  patched = true
  mainModule = require.main
  # Map of filenames -> sourceMap object.
  mainModule._sourceMaps or= {}

  # (Assigning to a property of the Module object in the normal module cache is
  # unsuitable, because node deletes those objects from the cache if an
  # exception is thrown in the module body.)

  Error.prepareStackTrace = (err, stack) ->
    sourceFiles = {}

    getSourceMapping = (filename, line, column) ->
      sourceMap = mainModule._sourceMaps[filename]
      answer = sourceMap.sourceLocation [line - 1, column - 1] if sourceMap
      if answer then [answer[0] + 1, answer[1] + 1] else null

    frames = for frame in stack
      break if frame.getFunction() is exports.run
      "  at #{formatSourcePosition frame, getSourceMapping}"

    "#{err.name}: #{err.message ? ''}\n#{frames.join '\n'}\n"

# Based on http://v8.googlecode.com/svn/branches/bleeding_edge/src/messages.js
# Modified to handle sourceMap
formatSourcePosition = (frame, getSourceMapping) ->
  fileName = undefined
  fileLocation = ''

  if frame.isNative()
    fileLocation = "native"
  else
    if frame.isEval()
      fileName = frame.getScriptNameOrSourceURL()
      fileLocation = "#{frame.getEvalOrigin()}, " unless fileName
    else
      fileName = frame.getFileName()

    fileName or= "<anonymous>"

    line = frame.getLineNumber()
    column = frame.getColumnNumber()

    # Check for a sourceMap position
    source = getSourceMapping fileName, line, column
    fileLocation =
      if source
        "#{fileName}:#{source[0]}:#{source[1]}, <js>:#{line}:#{column}"
      else
        "#{fileName}:#{line}:#{column}"


  functionName = frame.getFunctionName()
  isConstructor = frame.isConstructor()
  isMethodCall = not (frame.isToplevel() or isConstructor)

  if isMethodCall
    methodName = frame.getMethodName()
    typeName = frame.getTypeName()

    if functionName
      tp = as = ''
      if typeName and functionName.indexOf typeName
        tp = "#{typeName}."
      if methodName and functionName.indexOf(".#{methodName}") isnt functionName.length - methodName.length - 1
        as = " [as #{methodName}]"

      "#{tp}#{functionName}#{as} (#{fileLocation})"
    else
      "#{typeName}.#{methodName or '<anonymous>'} (#{fileLocation})"
  else if isConstructor
    "new #{functionName or '<anonymous>'} (#{fileLocation})"
  else if functionName
    "#{functionName} (#{fileLocation})"
  else
    fileLocation


mapped = (filename, sourceMap) ->
  require.main._sourceMaps or= {}
  require.main._sourceMaps[filename] = sourceMap
