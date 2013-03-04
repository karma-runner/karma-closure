expect = require('chai').expect
IitFilter = require '../lib/iit'

REGULAR_CONTENT = '''
it('should', function() {
  // whatever
});
'''

IIT_CONTENT = '''
iit('should', function() {
  // whatever
});
'''

DDESCRIBE_CONTENT = '''
ddescribe('whatever', function() {});
'''

describe 'IitFilter', ->
  iitFilter = null

  beforeEach ->
    iitFilter = new IitFilter

  it 'should not filter when empty', ->
    expect(iitFilter.isInclusive()).to.equal false


  it 'should filter only iit files', ->
    iitFilter.updateFile '/regular/file.js', REGULAR_CONTENT
    iitFilter.updateFile '/some/file.js', IIT_CONTENT

    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/regular/file.js').to.equal false
    expect(iitFilter.filter '/some/file.js').to.equal true


  it 'should remove the filter when iit removed', ->
    iitFilter.updateFile '/regular/file.js', REGULAR_CONTENT
    iitFilter.updateFile '/some/file.js', IIT_CONTENT
    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/regular/file.js').to.equal false

    iitFilter.updateFile '/some/file.js', REGULAR_CONTENT
    expect(iitFilter.isInclusive()).to.equal false
    expect(iitFilter.filter '/regular/file.js').to.equal true
    expect(iitFilter.filter '/some/file.js').to.equal true


  it 'should filter only ddescribe files', ->
    iitFilter.updateFile '/regular/file.js', REGULAR_CONTENT
    iitFilter.updateFile '/some/file.js', DDESCRIBE_CONTENT

    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/regular/file.js').to.equal false
    expect(iitFilter.filter '/some/file.js').to.equal true


  it 'should remove the filter when ddescribe removed', ->
    iitFilter.updateFile '/regular/file.js', REGULAR_CONTENT
    iitFilter.updateFile '/some/file.js', DDESCRIBE_CONTENT
    expect(iitFilter.isInclusive()).to.equal true

    iitFilter.updateFile '/some/file.js', REGULAR_CONTENT
    expect(iitFilter.isInclusive()).to.equal false
    expect(iitFilter.filter '/regular/file.js').to.equal true
    expect(iitFilter.filter '/some/file.js').to.equal true


  it 'should ignore ddescribe when iit present', ->
    iitFilter.updateFile '/some/dd.js', DDESCRIBE_CONTENT
    iitFilter.updateFile '/some/ii.js', IIT_CONTENT

    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/some/dd.js').to.equal false
    expect(iitFilter.filter '/some/ii.js').to.equal true


  it 'should filter only ddescribe when the only iit removed', ->
    iitFilter.updateFile '/some/other.js', REGULAR_CONTENT
    iitFilter.updateFile '/some/dd.js', DDESCRIBE_CONTENT
    iitFilter.updateFile '/some/ii.js', IIT_CONTENT
    iitFilter.updateFile '/some/ii.js', REGULAR_CONTENT

    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/some/other.js').to.equal false
    expect(iitFilter.filter '/some/dd.js').to.equal true
    expect(iitFilter.filter '/some/ii.js').to.equal false


  it 'should filter ddescribe even if the only iit replaced with ddescribe', ->
    iitFilter.updateFile '/some/file.js', IIT_CONTENT
    iitFilter.updateFile '/some/file.js', DDESCRIBE_CONTENT

    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/some/file.js').to.equal true


  it 'should remove inclusive if the only iit file removed', ->
    iitFilter.updateFile '/some/dd.js', DDESCRIBE_CONTENT
    iitFilter.updateFile '/some/ii.js', IIT_CONTENT
    iitFilter.removeFile '/some/ii.js'

    expect(iitFilter.isInclusive()).to.equal true
    expect(iitFilter.filter '/some/dd.js').to.equal true

    iitFilter.removeFile '/some/dd.js'
    expect(iitFilter.isInclusive()).to.equal false
