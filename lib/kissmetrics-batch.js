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
      var _ref;

      this._transformData(data);
      if ((_ref = data.timestamp) == null) {
        data.timestamp = Math.round((new Date).getTime() / 1000);
      }
      return this.queue.add(data);
    };

    BatchKissmetricsClient.process = function(queue, apiKey, apiSecret, productGUID) {
      var http, request, signature, urlPath, urlToSign;

      http = require('http');
      urlPath = "" + BatchKissmetricsClient.API_VERSION + "/products/" + productGUID + "/tracking/e";
      urlToSign = "http://" + BatchKissmetricsClient.HOST + "/" + urlPath;
      signature = BatchKissmetricsClient._generateSignature(urlToSign, apiSecret);
      request = http.request({
        method: BatchKissmetricsClient.HTTP_METHOD,
        host: BatchKissmetricsClient.HOST,
        path: "/" + urlPath + "?_signature=" + signature,
        headers: {
          'X-KM-ApiKey': apiKey,
          'Connection': 'close'
        }
      });
      request.end(JSON.stringify({
        data: queue.get()
      }));
      return request;
    };

    BatchKissmetricsClient._generateSignature = function(urlToSign, apiSecret) {
      var crypto, encodedRequest, signer;

      crypto = require('crypto');
      signer = crypto.createHmac('sha256', apiSecret);
      encodedRequest = [BatchKissmetricsClient.HTTP_METHOD, encodeURIComponent(urlToSign)].join('&');
      return encodeURIComponent(signer.update(encodedRequest).digest('base64'));
    };

    BatchKissmetricsClient.prototype._transformData = function(data) {
      data.identity = data._p;
      if (data._t) {
        data.timestamp = data._t;
      }
      switch (data.__type) {
        case 'record':
          data.event = data._n;
          break;
        case 'alias':
          data.alias = data._n;
      }
      delete data._k;
      delete data._n;
      delete data._p;
      delete data._t;
      delete data._d;
      return delete data.__type;
    };

    return BatchKissmetricsClient;

  }).call(this);

  module.exports = BatchKissmetricsClient;

}).call(this);
