should = require 'should'
KM     = require '../../src/kissmetrics'
Batch  = require '../../src/kissmetrics-batch'

testQueue =
  queue: []
  add: (data) ->
    @queue.push data
  get: ->
    @queue
  clear: ->
    @queue = []

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

describe 'Send batch data', ->
  it 'should generate endpoint', ->
    km = new KM 'fakeApiKey', 'test@example.com', {batch: {queue: testQueue}}
    testQueue.queue[0].timestamp = 1364563642
    km.record 'Visited Homepage'


    request = Batch.process testQueue, 'fakeApiKey', 'fakeApiSecret', 'fakeProductGUID'
    endpoint = request.output.pop().split(/\n/)[0].trim()
    endpoint.should.equal 'POST http://api.kissmetrics.com/v1/products/fakeProductGUID/tracking/e?_signature=L5JAfOuh62iWmHCZMa2iT03L4doPGMM4kSOhoJNNIoM%3D HTTP/1.1'

  it 'should send API key header', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('these').record('should').record('batch')

    request = Batch.process testQueue, 'exApiKey', 'exApiSecret', 'exProductGUID'
    request.output.pop().should.match /X-KM-ApiKey: exApiKey/

  it 'should use API host', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('these').record('should').record('batch')

    request = Batch.process testQueue, 'exApiKey', 'exApiSecret', 'exProductGUID'
    request.output.pop().should.match /Host: api.kissmetrics.com/

  it 'should stringify data', ->
    testQueue.queue = []
    km = new KM 'apiKey', 'evan@example.com', {batch: {queue: testQueue}}
    km.record('these').record('should').record('batch')

    expectedOutput = """
      {"data":[{"_k":"apiKey","timestamp":_TIMESTAMP_,"identity":"evan@example.com","event":"these"},{"_k":"apiKey","timestamp":_TIMESTAMP_,"identity":"evan@example.com","event":"should"},{"_k":"apiKey","timestamp":_TIMESTAMP_,"identity":"evan@example.com","event":"batch"}]}
      """

    request = Batch.process testQueue, 'exApiKey', 'exApiSecret', 'exProductGUID'
    output = request.output.pop().split(/\n/)
    output = output[output.length - 2].trim()

    outputTimestamp = output.match(/timestamp":([0-9]+)/).pop()
    expectedOutput = expectedOutput.replace /_TIMESTAMP_/g, outputTimestamp
    output.should.equal expectedOutput
