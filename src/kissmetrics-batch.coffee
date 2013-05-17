# # Kissmetrics Batch

class BatchKissmetricsClient
  @HOST: 'api.kissmetrics.com'
  @HTTP_METHOD: 'POST'
  @API_VERSION: 'v1'

  @process: (queue, apiKey, apiSecret, productGUID) ->
    http = require 'http'

    apiVersion = BatchKissmetricsClient.API_VERSION
    urlPath    = "#{apiVersion}/products/#{productGUID}/tracking/e"
    baseUrl    = "http://#{BatchKissmetricsClient.HOST}/#{urlPath}"
    signature  = BatchKissmetricsClient._generateSignature baseUrl, apiSecret
    # return "#{baseUrl}?_signature=#{signature}"

    request = http.request
      host: BatchKissmetricsClient.HOST
      path: "#{baseUrl}?_signature=#{signature}"
      headers:
        'X-KM-ApiKey': apiKey

    requestBody = JSON.stringify {data: queue.get()}
    request.write requestBody

    queue.clear()
    return request

  @_generateSignature: (url, apiSecret) ->
    'temporary-signature'

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
