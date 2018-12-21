expect = require('chai').expect
DependencyResolver = require '../lib/resolver'
logger = {'create': -> logger}

describe 'DependencyResolver', ->
  it 'should sort topologically', ->
    resolver = new DependencyResolver(logger)
    resolver.updateFile('a.js', '''
      goog.provide("a")
    ''')
    resolver.updateFile('b.js', '''
      goog.provide("b")
      goog.require("a")
    ''')
    resolver.updateFile('c.js', '''
      goog.provide("c")
      goog.require("b")
    ''')

    expect(resolver.resolveFiles ['c.js']).to.deep.equal ['a.js', 'b.js', 'c.js']
    
  it 'should only resolve each file once', ->
    resolver = new DependencyResolver(logger)
    resolver.updateFile('a.js', '''
      goog.provide("a")
    ''')
    resolver.updateFile('b.js', '''
      goog.provide("b")
      goog.require("a")
    ''')

    expect(resolver.resolveFiles ['a.js', 'b.js']).to.deep.equal ['a.js', 'b.js']
    expect(resolver.resolveFiles ['b.js', 'a.js']).to.deep.equal ['a.js', 'b.js']

