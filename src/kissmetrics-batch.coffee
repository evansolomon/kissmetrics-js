# # Kissmetrics Batch

class BatchKissmetricsClient
  @HOST: 'api.kissmetrics.com'
  @HTTP_METHOD: 'POST'
  @API_VERSION: 'v1'

  @process: (queue, apiKey, apiSecret, productGUID) =>
    http = require 'http'

    urlPath   = "#{@API_VERSION}/products/#{productGUID}/tracking/e"
    baseUrl   = "http://#{@HOST}/#{urlPath}"
    signature = @_generateSignature baseUrl, apiSecret

    request = http.request
      method: @HTTP_METHOD
      host: @HOST
      path: "/#{urlPath}?_signature=#{signature}"
      headers:
        'X-KM-ApiKey': apiKey
        'Connection': 'close'

    request.end JSON.stringify(queue.get())
    queue.done()
    request

  @_generateSignature: (baseUrl, apiSecret) =>
    crypto = require 'crypto'
    signer = crypto.createHmac 'sha256', apiSecret

    encodedRequest = [@HTTP_METHOD, encodeURIComponent baseUrl].join('&')
    encodeURIComponent signer.update(encodedRequest).digest('base64')

  constructor: (@queue) ->

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
