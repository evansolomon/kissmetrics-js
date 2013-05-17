should = require 'should'
KM     = require '../../src/kissmetrics'

testQueue =
  queue: []
  add: (data) ->
    @queue.push data
  get: ->
    @queue

describe 'KM batch instance', ->
  it 'should initialize', ->
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.apiKey.should.equal 'apiKey'
    km.person.should.equal 'evan@example.com'

  it 'should fail with invalid queue', ->
    failedQueue =
      queue: []
      add: 'not a function'
      get: ->
        @queue

    failToAdd = ->
      km = new KM 'apiKey', 'evan@example.com', {batch: {queue: failedQueue}}
      km.record('foo')

    failToAdd.should.throw()


describe 'Use the queue', ->
  it 'should add queries to queue', ->
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record 'did foo'

    testQueue.queue.length.should.equal 1

  it 'should not add queued queries to query list', ->
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record 'did foo'

    km.queries.length.should.equal 0

  it 'should get queries from queue', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('foo').record('bar').alias('another person').set({home: 'neverland'})

    testQueue.get().length.should.equal 4

describe 'Process batch API data', ->
  it 'should transform event names', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('some kind of event')

    testQueue.get()[0].event.should.be.ok
    should.not.exist testQueue.get()[0]._n

  it 'should add timestamps', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('some kind of event')

    testQueue.get()[0].timestamp.should.be.a 'number'

  it 'should transform alias event', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.alias('tyler durden')

    testQueue.get()[0].alias.should.be.ok
    should.not.exist testQueue.get()[0]._n

  it 'should remove type property', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('foo')

    should.not.exist testQueue.get()[0].type
