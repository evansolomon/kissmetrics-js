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

    BatchKissmetricsClient.prototype.add = function(data) {
      return this.queue.add(this._transformData(data));
    };

    BatchKissmetricsClient.process = function(queue, apiKey, apiSecret, productGUID) {
      var http, request, requestBody, signature, urlPath, urlToSign;

      http = require('http');
      urlPath = "" + BatchKissmetricsClient.API_VERSION + "/products/" + productGUID + "/tracking/e";
      urlToSign = "http://" + BatchKissmetricsClient.HOST + "/" + urlPath;
      signature = BatchKissmetricsClient._generateSignature(urlToSign, apiSecret);
      requestBody = JSON.stringify({
        data: queue.get()
      });
      request = http.request({
        method: BatchKissmetricsClient.HTTP_METHOD,
        host: BatchKissmetricsClient.HOST,
        path: "/" + urlPath + "?_signature=" + signature,
        headers: {
          'X-KM-ApiKey': apiKey,
          'Connection': 'close',
          'Content-Length': requestBody.length
        }
      });
      request.end(requestBody);
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
      var reservedKey, reservedKeys, _i, _len;

      data.identity = data._p;
      data.timestamp = data._t || Math.round((new Date).getTime() / 1000);
      switch (data.__type) {
        case 'record':
          data.event = data._n;
          break;
        case 'alias':
          data.alias = data._n;
      }
      reservedKeys = ['_k', '_n', '_p', '_t', '_d', '__type'];
      for (_i = 0, _len = reservedKeys.length; _i < _len; _i++) {
        reservedKey = reservedKeys[_i];
        delete data[reservedKey];
      }
      return data;
    };

    return BatchKissmetricsClient;

  }).call(this);

  module.exports = BatchKissmetricsClient;

}).call(this);
