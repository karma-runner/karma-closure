expect = require('chai').expect
goog = require '../lib/goog'

describe 'goog.parseProvideRequire', ->
  parseProvideRequire = goog.parseProvideRequire

  it 'should parse basics', ->
    parsed = parseProvideRequire '''
    // some comment
    goog.provide("a.b");
    goog.require("a.c");
    '''

    expect(parsed.provides).to.deep.equal ['a.b']
    expect(parsed.requires).to.deep.equal ['a.c']


  it 'should sort alphabetically', ->
    parsed = parseProvideRequire '''
    goog.require("c")
    goog.require("a")
    goog.provide("c")
    goog.provide("b")
    goog.require("b")
    goog.provide("a")
    '''

    expect(parsed.provides).to.deep.equal ['a', 'b', 'c']
    expect(parsed.requires).to.deep.equal ['a', 'b', 'c']


  it 'should parse single quotes', ->
    parsed = parseProvideRequire '''
    goog.provide('a.b');
    goog.require('a.c');
    '''

    expect(parsed.provides).to.deep.equal ['a.b']
    expect(parsed.requires).to.deep.equal ['a.c']


describe 'goog.parseDepsJs', ->
  parseDepsJs = goog.parseDepsJs

  it 'should evaluate deps.js and produce fileMap and provideMap', ->
    parsed = parseDepsJs '/some/deps.js', '''
    /* some comment */
    goog.addDependency('/html/htmlparser.js', ['html.HtmlParser', 'html.EFlags'], ['goog.string']);
    goog.addDependency('/dom/query.js', ['dom.query'], ['goog.array', 'goog.dom']);
    '''

    expect(parsed.fileMap).to.deep.equal {
      '/html/htmlparser.js':
        provides: ['html.HtmlParser', 'html.EFlags']
        requires: ['goog.string']
      '/dom/query.js':
        provides: ['dom.query']
        requires: ['goog.array', 'goog.dom']
    }

    expect(parsed.provideMap).to.deep.equal {
        'html.HtmlParser': '/html/htmlparser.js'
        'html.EFlags': '/html/htmlparser.js'
        'dom.query': '/dom/query.js'
    }


  it 'should resolve relative paths to deps.js location', ->
    parsed = parseDepsJs '/some/a/b/deps.js', '''
    goog.addDependency('../../other/lib.js', ['provide.a'], ['require.b'])
    '''

    expect(parsed.fileMap).to.have.property '/some/other/lib.js'
    expect(parsed.fileMap['/some/other/lib.js']).to.deep.equal {
      provides: ['provide.a']
      requires: ['require.b']
    }
