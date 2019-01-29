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
    
  it 'should emit errors on circular dependencies', ->
    resolver = new DependencyResolver(logger)
    resolver.updateFile('a.js', '''
      goog.provide("a")
      goog.require("b")
    ''')
    resolver.updateFile('b.js', '''
      goog.provide("b")
      goog.require("a")
    ''')

    log = []
    logger.error = (messages...) -> log.push.apply(log, messages)
    resolver.resolveFiles ['b.js']
    expect(log).to.deep.equal ['CIRCULAR DEPENDENCY:', 'b.js <- a.js <- b.js']

