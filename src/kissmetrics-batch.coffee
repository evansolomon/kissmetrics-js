# # Batch Kissmetrics
# -------------------

# Wrapper for queuing batch queries and processing the batch queue. It's
# unlikely you should create instances of this class directly. It is used
# internally by the `KissmetricsClient` class.
#
# ##### Arguments
#
# `queue` (Object): An object with an `add()` method that can append queries
#   to the batch queue. Queries will be passed as objects and must
#   be retrievable as objects.
#
# ```
# queue = {
#   add: function(obj) {
#     someQueue.add({key: 'kissmetrics', data: obj});
#   }
# };
# batch = new BatchKissmetricsClient(queue);
# ```

class BatchKissmetricsClient
  @HOST: 'api.kissmetrics.com'
  @HTTP_METHOD: 'POST'
  @API_VERSION: 'v1'

  constructor: (@queue) ->


  # ### Add
  # -------

  # Add a query to the queue.
  #
  # ##### Arguments
  #
  # `data` (Object): Key/value pairs of Kissmetrics properties. Some
  #   properties will be renamed in `_transformData()` based on `data.type`
  #   due to differences between Kissmetrics' batch API and regular HTTP API.
  #
  # ```
  # batch.add({name: 'Evan', home: 'San Francisco'}, 482698020);
  # ```

  add: (data) ->
    @queue.add @_transformData data


  # ### Process
  # #### (Static)
  # -------------

  # Process the queue of batched queries by sending them to Kissmetrics.
  #
  # ##### Arguments
  #
  # `queue` (Object): Must have a `get()` method and it should
  #   return an array of queued queries.
  #
  # `apiKey` (String): Your API key from Kissmetrics. This is specific to
  #   the batch API and *different* than your regular Kissmetrics API key.
  #
  # `apiSecret` (String): Your API secret from Kissmetrics.
  #
  # `productGUID` (String): Your Product GUID from Kissmetrics.
  #
  # ```
  # queue = {
  #   get: function() {
  #     this.queue = someQueue.get('kissmetrics');
  #     return this.queue.data;
  #   }
  # };
  # Batch.process(queue, 'key', 'secret-key', 'SOME-PRODUCT');
  # ```

  @process: (queue, apiKey, apiSecret, productGUID) =>
    http = require 'http'

    urlPath   = "#{@API_VERSION}/products/#{productGUID}/tracking/e"
    urlToSign = "http://#{@HOST}/#{urlPath}"
    signature = @_generateSignature urlToSign, apiSecret

    requestBody = JSON.stringify {data: queue.get()}

    request = http.request
      method: @HTTP_METHOD
      host: @HOST
      path: "/#{urlPath}?_signature=#{signature}"
      headers:
        'X-KM-ApiKey': apiKey
        'Connection': 'close'
        'Content-Length': requestBody.length

    request.end requestBody
    request


  # ### Generate Signature
  # #### (Private, Static)
  # ----------------------

  # Generate a signature for a batch request URL. Based on Kissmetrics'
  # UriSigner library: https://github.com/kissmetrics/uri_signer
  #
  # ##### Arguments
  #
  # `urlToSign` (String): The URL (including path) that the request will
  #   be sent to.
  #
  # `apiSecret` (String): Your API secret from Kissmetrics.

  @_generateSignature: (urlToSign, apiSecret) =>
    crypto = require 'crypto'
    signer = crypto.createHmac 'sha256', apiSecret

    encodedRequest = [@HTTP_METHOD, encodeURIComponent urlToSign].join('&')
    encodeURIComponent signer.update(encodedRequest).digest('base64')


  # ### Transform Data
  # #### (Private)
  # ------------------

  # Rename keys that differ between Kissmetrics' batch API and regular
  # HTTP API.
  #
  # * `_p` (person) is replaced by `identity`
  # * `_t` (timestamp) is replaced by `timestamp`
  # * `_d` (date provided) is ignored because all batch queries provide dates
  # * `record` queries use the `event` property instead of `_n`
  # * `alias` queries use the `alias` property instead of `_n`
  # * `_k` (API key) is replaced by an HTTP header
  # * `__type` is only used internally
  #
  # ##### Arguments
  #
  # `data` (Object): Key/value pairs of properties to send to Kissmetrics.

  _transformData: (data) ->
    data.identity = data._p
    data.timestamp = data._t || Math.round(Date.now() / 1000)

    switch data.__type
      when 'record' then data.event = data._n
      when 'alias' then data.alias = data._n

    reservedKeys = ['_k', '_n', '_p', '_t', '_d', '__type']
    delete data[reservedKey] for reservedKey in reservedKeys

    data


# ## Exports
# -----------

# Expose BatchKissmetricsClient as a Node.js module.

module.exports = BatchKissmetricsClient
