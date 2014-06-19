example = require '../lib/example'
expect = require('chai').expect

describe 'The example module', ->

  it 'should export an echo method', ->
    expect(example.echo).not.to.be.undefined

  describe 'the echo method', ->

    it 'should return the first argument passed', ->
      expect(example.echo 'x').to.equal('x')
