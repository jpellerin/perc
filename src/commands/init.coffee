fs = require 'fs'
path = require 'path'
http = require 'http'
{exec} = require 'child_process'

dlog = require('debug')('perc:init')
eco = require 'eco'
temp = require 'temp'
wrench = require 'wrench'

skeleton = path.join __dirname, '../../skeleton'


module.exports = command =
  help: "Initialize a project from a skeleton"
  init: (command, config) ->
    plist = (val) ->
      props = {}
      for pair in val.split ','
        [n, v] = pair.split ':'
        props[n] = v
      props

    command.option '-S, --skeleton [SKELETON]', 'Skeleton path or url', skeleton
    command.option '--set [NAME:VALUE,NAME:VALUE]',
      'Set project package config variable', plist
    command.usage "<path> [options]\n\n  #{@help}"

  run: (command, config, args) ->
    opts =
      source: command.skeleton
      skeleton: command.skeleton
      target: path.resolve args[0] ? process.cwd()
      set: command.set
    getSkeleton opts


getSkeleton = (opts) ->
  type = guessType opts.skeleton
  if type is 'http'
    getHttpSkeleton opts, copySkeleton
  else if type is 'git'
    getGitSkeleton opts, copySkeleton
  else
    copySkeleton opts


copySkeleton = (opts, next=(->)) ->
  dlog "Copy #{opts.skeleton} to #{opts.target}"
  wopts =
    preserve: true
    preserveFiles: true
    filter: /~$/
    excludeHiddenUnix: true
    whitelist: false

  wrench.copyDirSyncRecursive opts.skeleton, opts.target, wopts
  console.log "Copied skeleton from #{opts.source} into #{opts.target}"

  if opts.set
    ppath = path.join(opts.target, 'package.json')
    pkg = JSON.parse fs.readFileSync(ppath, 'utf-8')
    for prop, val of opts.set
      pkg[prop] = val
    fs.writeFileSync ppath, JSON.stringify(pkg)
    console.log "Set package.json properties: " +
      "#{[prop for prop, val of opts.set].join(', ')}"
  next opts


getHttpSkeleton = (opts, next) ->
  inTempDir (dirPath, clean) ->
    console.log "Downloading skeleton from #{opts.skeleton}..."
    http.get opts.skeleton, (res) ->
      pkgFile = path.join dirPath, 'pkg.tgz'
      pkgPath = path.join dirPath, 'pkg'
      dlog "Downloading #{opts.skeleton} to #{pkgFile}"

      pkg = fs.createWriteStream pkgFile

      res.on 'error', (error) ->
        dlog "Http error #{error}"
        clean()
        exitErr error

      res.on 'data', (chunk) ->
        dlog "data #{chunk.length} bytes"
        pkg.write chunk

      res.on 'end', ->
        console.log "Download complete"
        pkg.end()

        unpack pkgFile, pkgPath, clean, (unpacked) ->
          opts.skeleton = unpacked
          next opts, clean


getGitSkeleton = (opts, next) ->
  inTempDir (dirPath, clean) ->
    console.log "Cloning #{opts.skeleton}..."
    pkgPath = path.join dirPath, 'pkgDir'
    exec "git clone #{opts.skeleton} #{pkgPath}", (error, stdout, stderr) =>
      dlog "cloned #{opts.skeleton} into #{pkgPath}"
      if error
        clean()
        exitErr error
      console.log "Clone complete"
      opts.skeleton = pkgPath
      next opts, clean


inTempDir = (next) ->
  temp.mkdir 'perc-init', (err, dirPath) =>
    if err
      exitErr err

    clean = ->
      wrench.rmdirSyncRecursive dirPath
      dlog "Removed #{dirPath}"

    process.on 'uncaughtException', (err) ->
      clean()
      exitErr err

    next dirPath, clean


guessType = (dirOrUrl) ->
  try
    st = fs.lstatSync dirOrUrl
    if st.isDirectory()
      return 'directory'
    else
      exitErr "#{dirOrUrl} exists but is not a directory"
  catch e
    if dirOrUrl.match /^https?:\/\/.*gz$/
      dlog "Guessing http"
      return 'http'
    else if dirOrUrl.match '^(git|https?):\/\/'
      dlog "Guessing git"
      return 'git'
    else
      exitErr "Can't figure out what #{dirOrUrl} is"


exitErr = (err) ->
  dlog "Error #{err}"
  console.error "Init failed: #{err}"
  process.exit 1


unpack = (pkg, pkgPath, clean, next) ->
  targz = require 'tar.gz'
  new targz().extract pkg, pkgPath, (err) ->
    if err
      clean()
      exitErr err
    dlog "Unpacked #{pkg} to #{pkgPath}"
    files = fs.readdirSync pkgPath
    skeleton =
      if files.length is 1
        path.join(pkgPath, files[0])
      else
        pkgPath
    dlog "Skeleton dir is #{skeleton}"
    next skeleton
