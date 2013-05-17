# # Kissmetrics Batch

class BatchKissmetricsClient
  @HOST: 'api.kissmetrics.com'
  @HTTP_METHOD: 'POST'

  @process: (apiKey) ->
    queue = @get()

  constructor: (@options) ->
    @queue = options.queue
    @_validate_queue @queue

  add: (timestamp, data) ->
    data.timestamp = timestamp
    @_transformData data

    @queue.add data

  get: ->
    @queue.get()

  _transformData: (data) ->
    data.identity = data._p
    delete data._p

    if data.type is 'record'
      data.event = data._n
      delete data._n

    if data.type is 'alias'
      data.alias = data._n
      delete data._n

    delete data.type

  _validate_queue: ->
    for required_method in ['add', 'get']
      unless typeof @queue[required_method] is 'function'
        throw new Error "Missing method: #{required_method}"


module.exports = BatchKissmetricsClient
