/**
 * Kissmetrics JS
 * https://github.com/evansolomon/kissmetrics-js
 * Copyright (c) 2013
 * Evan Solomon; Licensed MIT
 */

(function() {
  var ENV, KissmetricsClient, httpRequest, https;

  ENV = typeof exports !== 'undefined' ? 'node' : 'browser';

  if (ENV === 'node') {
    https = require('https');
  }

  httpRequest = function(url) {
    if (ENV === 'node') {
      return https.get(url);
    } else {
      return (new Image()).src = url;
    }
  };

  KissmetricsClient = (function() {

    function KissmetricsClient(key, person) {
      this.key = key;
      this.person = person;
      this.host = 'trk.kissmetrics.com';
      this.port = 80;
      this.query_types = {
        record: 'e',
        set: 's',
        alias: 'a'
      };
    }

    KissmetricsClient.prototype.record = function(action, properties) {
      if (properties == null) {
        properties = {};
      }
      properties._n = action;
      return this._generateQuery('record', properties);
    };

    KissmetricsClient.prototype.set = function(properties) {
      var data, name, value, _results;
      _results = [];
      for (name in properties) {
        value = properties[name];
        data = {};
        data[name] = value;
        _results.push(this._generateQuery('set', data));
      }
      return _results;
    };

    KissmetricsClient.prototype.alias = function(to) {
      return this._generateQuery('alias', {
        _n: to
      });
    };

    KissmetricsClient.prototype._generateQuery = function(type, data) {
      var key, queryParts, queryString, val;
      data._k = this.key;
      data._p = this.person;
      queryParts = [];
      for (key in data) {
        val = data[key];
        queryParts.push("" + (encodeURIComponent(key)) + "=" + (encodeURIComponent(val)));
      }
      queryString = queryParts.join('&');
      return this._request("" + this.query_types[type] + "?" + queryString);
    };

    KissmetricsClient.prototype._request = function(endpoint) {
      return httpRequest("https://" + this.host + ":" + this.port + "/" + endpoint);
    };

    return KissmetricsClient;

  })();

  if (ENV === 'node') {
    exports.KissmetricsClient = KissmetricsClient;
  } else {
    this.KissmetricsClient = KissmetricsClient;
  }

}).call(this);
