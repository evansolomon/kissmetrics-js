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

  httpRequest = function(args) {
    var url, _ref, _ref1;
    if ((_ref = args.port) == null) {
      args.port = 80;
    }
    if ((_ref1 = args.path) == null) {
      args.path = '';
    }
    url = "https://" + args.host + ":" + args.port + "/" + args.path;
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
      return this.generateQuery('record', properties);
    };

    KissmetricsClient.prototype.set = function(properties) {
      var data, name, value, _results;
      _results = [];
      for (name in properties) {
        value = properties[name];
        data = {};
        data[name] = value;
        _results.push(this.generateQuery('set', data));
      }
      return _results;
    };

    KissmetricsClient.prototype.alias = function(to) {
      return this.generateQuery('alias', {
        _n: to
      });
    };

    KissmetricsClient.prototype.generateQuery = function(type, data) {
      var key, queryParts, queryString, val;
      data._k = this.key;
      data._p = this.person;
      queryParts = (function() {
        var _results;
        _results = [];
        for (key in data) {
          val = data[key];
          _results.push("" + (encodeURIComponent(key)) + "=" + (encodeURIComponent(val)));
        }
        return _results;
      })();
      queryString = queryParts.join('&');
      return this.request("" + this.query_types[type] + "?" + queryString);
    };

    KissmetricsClient.prototype.request = function(endpoint) {
      return httpRequest({
        host: this.host,
        port: this.port,
        path: endpoint
      });
    };

    return KissmetricsClient;

  })();

  if (ENV === 'node') {
    exports.KissmetricsClient = KissmetricsClient;
  } else {
    this.KissmetricsClient = KissmetricsClient;
  }

}).call(this);
