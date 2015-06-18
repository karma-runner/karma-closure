expect = require('chai').expect
shadow = require '../lib/shadow'

describe 'shadow map', ->

  it 'should initialize empty', ->
    amap = shadow()
    expect(shadow).to.be.a 'function'
    expect(amap).to.be.a 'object'
    expect(amap.get).to.be.a 'function'
    expect(amap.set).to.be.a 'function'
    expect(amap.has).to.be.a 'function'
    expect(amap.add).to.be.a 'function'
    expect(amap.get('foo')).to.equal undefined
    expect(amap.get(undefined)).to.equal undefined
    expect(amap.get(null)).to.equal undefined

  it 'should get and set values properly', ->
    amap = shadow()
    expect(amap.get('a')).to.equal undefined
    expect(amap.has('a')).to.equal false
    expect(amap.set('a', 'x')).to.equal undefined
    expect(amap.get('a')).to.equal 'x'
    expect(amap.has('a')).to.equal true

    expect(amap.set('a', 'y')).to.equal undefined
    expect(amap.get('a')).to.equal 'y'
    expect(amap.has('a')).to.equal true

  it 'should handle two objects with second as fallback', ->
    amap = shadow()
    expect(amap.set('a', 'x')).to.equal undefined

    expect(amap.get('a')).to.equal 'x'
    expect(amap.has('a')).to.equal true

    expect(amap.get('b')).to.equal undefined
    expect(amap.has('b')).to.equal false

    amap.add({ 'a': 'y', 'b': 'z' })

    expect(amap.get('b')).to.equal 'z'
    expect(amap.has('b')).to.equal true

    expect(amap.get('a')).to.equal 'x'
    expect(amap.has('a')).to.equal true

    expect(amap.set('b', '0')).to.equal undefined
    expect(amap.get('b')).to.equal '0'
    expect(amap.has('b')).to.equal true

  it 'should handle three objects', ->
    amap = shadow()
    two = {}
    three = {}
    amap.add(two)
    amap.add(three)

    expect(amap.get('a')).to.equal undefined
    expect(amap.has('a')).to.equal false

    three.a = 'z'
    expect(amap.get('a')).to.equal 'z'
    expect(amap.has('a')).to.equal true

    two.a = 'y'
    expect(amap.get('a')).to.equal 'y'
    expect(amap.has('a')).to.equal true

    amap.set('a', 'x')
    expect(amap.get('a')).to.equal 'x'
    expect(amap.has('a')).to.equal true

    amap.set('a', undefined)
    expect(amap.get('a')).to.equal 'y'
    expect(amap.has('a')).to.equal true

  it 'should handle js wierdness', ->
    amap = shadow()

    expect(amap.get('__proto__')).to.equal undefined
    expect(amap.get('toString')).to.equal undefined

    bmap = shadow({})
    expect(bmap.get('__proto__')).to.equal undefined
    expect(bmap.get('toString')).to.equal undefined

  it 'should handle removing', ->
    amap = shadow()

    amap.set('a', 'x')
    expect(amap.get('a')).to.equal 'x'
    expect(amap.has('a')).to.equal true

    amap.rem('a')
    expect(amap.get('a')).to.equal undefined
    expect(amap.has('a')).to.equal false

    amap.add({'a': 'y'})
    expect(amap.get('a')).to.equal 'y'
    expect(amap.has('a')).to.equal true

    amap.set('a', 'x')
    expect(amap.get('a')).to.equal 'x'
    expect(amap.has('a')).to.equal true
