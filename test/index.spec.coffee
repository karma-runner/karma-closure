expect = require('chai').expect
index = require '../lib/index'

describe 'parseProvideRequire', ->
  parseProvideRequire = index.parseProvideRequire

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


describe 'equalSorted', ->
  equalSorted = index.equalSorted

  it 'should compare two sorted arrays', ->
    expect(equalSorted ['a', 'b'], ['a', 'b']).to.equal true
    expect(equalSorted ['a', 'b', 'c'], ['a', 'b']).to.equal false
    expect(equalSorted ['a', 'c'], ['a', 'b']).to.equal false

describe 'diffSorted', ->
  diffSorted = index.diffSorted

  it 'should return null if both arrays are equal', ->
    expect(diffSorted ['a', 'b'], ['a', 'b']).to.equal null


  it 'should return added and removed elements', ->
    diff = diffSorted ['a', 'b'], ['a', 'c']

    expect(diff.added).to.deep.equal ['c']
    expect(diff.removed).to.deep.equal ['b']
