/**
 * Kissmetrics JS
 * https://github.com/evansolomon/kissmetrics-js
 * Copyright (c) 2013
 * Evan Solomon; Licensed MIT
 */

//@ sourceMappingURL=kissmetrics-batch.map
(function() {
  var BatchKissmetricsClient;

  BatchKissmetricsClient = (function() {
    BatchKissmetricsClient.HOST = 'api.kissmetrics.com';

    BatchKissmetricsClient.HTTP_METHOD = 'POST';

    BatchKissmetricsClient.API_VERSION = 'v1';

    function BatchKissmetricsClient(queue) {
      this.queue = queue;
    }

    BatchKissmetricsClient.prototype.add = function(data, timestamp) {
      if (timestamp == null) {
        timestamp = Math.round((new Date).getTime() / 1000);
      }
      data.timestamp = timestamp;
      this._transformData(data);
      return this.queue.add(data);
    };

    BatchKissmetricsClient.process = function(queue, apiKey, apiSecret, productGUID) {
      var baseUrl, http, request, signature, urlPath;

      http = require('http');
      urlPath = "" + BatchKissmetricsClient.API_VERSION + "/products/" + productGUID + "/tracking/e";
      baseUrl = "http://" + BatchKissmetricsClient.HOST + "/" + urlPath;
      signature = BatchKissmetricsClient._generateSignature(baseUrl, apiSecret);
      request = http.request({
        method: BatchKissmetricsClient.HTTP_METHOD,
        host: BatchKissmetricsClient.HOST,
        path: "/" + urlPath + "?_signature=" + signature,
        headers: {
          'X-KM-ApiKey': apiKey,
          'Connection': 'close'
        }
      });
      request.end(JSON.stringify(queue.get()));
      queue.done();
      return request;
    };

    BatchKissmetricsClient._generateSignature = function(baseUrl, apiSecret) {
      var crypto, encodedRequest, signer;

      crypto = require('crypto');
      signer = crypto.createHmac('sha256', apiSecret);
      encodedRequest = [BatchKissmetricsClient.HTTP_METHOD, encodeURIComponent(baseUrl)].join('&');
      return encodeURIComponent(signer.update(encodedRequest).digest('base64'));
    };

    BatchKissmetricsClient.prototype._transformData = function(data) {
      data.identity = data._p;
      switch (data.type) {
        case 'record':
          data.event = data._n;
          break;
        case 'alias':
          data.alias = data._n;
      }
      delete data._k;
      delete data._n;
      delete data._p;
      return delete data.type;
    };

    return BatchKissmetricsClient;

  }).call(this);

  module.exports = BatchKissmetricsClient;

}).call(this);
