# # Kissmetrics Batch

class BatchKissmetricsClient
  @HOST: 'api.kissmetrics.com'
  @HTTP_METHOD: 'POST'

  @process: (apiKey, queue) ->
    queue = queue.get()

  constructor: (@options) ->
    @queue = options.queue

  add: (timestamp, data) ->
    data.timestamp = timestamp
    @_transformData data

    @queue.add data

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

module.exports = BatchKissmetricsClient
