expect = require('chai').expect
utils = require '../lib/utils'


describe 'utils.equalSorted', ->
  equalSorted = utils.equalSorted

  it 'should compare two sorted arrays', ->
    expect(equalSorted ['a', 'b'], ['a', 'b']).to.equal true
    expect(equalSorted ['a', 'b', 'c'], ['a', 'b']).to.equal false
    expect(equalSorted ['a', 'c'], ['a', 'b']).to.equal false

describe 'utils.diffSorted', ->
  diffSorted = utils.diffSorted

  it 'should return null if both arrays are equal', ->
    expect(diffSorted ['a', 'b'], ['a', 'b']).to.equal null


  it 'should return added and removed elements', ->
    diff = diffSorted ['a', 'b'], ['a', 'c']

    expect(diff.added).to.deep.equal ['c']
    expect(diff.removed).to.deep.equal ['b']
