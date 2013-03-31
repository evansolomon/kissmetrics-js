/**
 * Kissmetrics JS
 * https://github.com/evansolomon/kissmetrics-js
 * Copyright (c) 2013
 * Evan Solomon; Licensed MIT
 */

//@ sourceMappingURL=kissmetrics.map
(function() {
  var AnonKissmetricsClient, Cookie, KissmetricsClient, KissmetricsStorage, LocalStorage, NODEJS, global, http, httpRequest,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  NODEJS = typeof exports !== 'undefined';

  if (NODEJS === true) {
    http = require('http');
  }

  httpRequest = function(url) {
    if (NODEJS === true) {
      return http.get(url);
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
      queryParts = (function() {
        var _results;

        _results = [];
        for (key in data) {
          val = data[key];
          key = encodeURIComponent(key);
          val = encodeURIComponent(val);
          _results.push("" + key + "=" + val);
        }
        return _results;
      })();
      queryString = queryParts.join('&');
      return this._request("" + this.query_types[type] + "?" + queryString);
    };

    KissmetricsClient.prototype._request = function(endpoint) {
      return httpRequest("http://" + this.host + ":" + this.port + "/" + endpoint);
    };

    return KissmetricsClient;

  })();

  global = NODEJS === true ? exports : this;

  global.KissmetricsClient = KissmetricsClient;

  LocalStorage = {
    set: function(key, value) {
      return window.localStorage.setItem(key, value);
    },
    "delete": function(key) {
      return window.localStorage.removeItem(key);
    },
    get: function(key) {
      return window.localStorage.getItem(key);
    }
  };

  Cookie = {
    set: function(key, value, options) {
      var date;

      if (options == null) {
        options = {
          expires: ''
        };
      }
      if (!options.expires) {
        date = new Date;
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
        options.expires = "expires=" + date.toGMTString();
      }
      return document.cookie = "" + name + "=" + value + "; " + options.expires + "; path=/";
    },
    get: function(key) {
      var cleanedPart, cookiePart, _i, _len, _ref;

      key += '=';
      _ref = document.cookie.split(';');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cookiePart = _ref[_i];
        cleanedPart = cookiePart.replace(/^\s+/, '').substring(key.length + 1, cookiePart.length);
        if (cleanedPart.indexOf(key === 0)) {
          return cleanedPart;
        }
      }
    },
    "delete": function(key) {
      return Cookie.set(key, '', {
        expires: -1
      });
    }
  };

  KissmetricsStorage = (function() {
    function KissmetricsStorage(key) {
      this.key = key;
      this.store = window.localStorage != null ? LocalStorage : Cookie;
    }

    KissmetricsStorage.prototype.set = function(value) {
      return this.store.set(this.key, value);
    };

    KissmetricsStorage.prototype.get = function() {
      return this.store.get(this.key);
    };

    KissmetricsStorage.prototype["delete"] = function() {
      return this.store["delete"](this.key);
    };

    return KissmetricsStorage;

  })();

  AnonKissmetricsClient = (function(_super) {
    __extends(AnonKissmetricsClient, _super);

    function AnonKissmetricsClient(key, options) {
      var person;

      if (options == null) {
        options = {
          key: 'kissmetricsAnon'
        };
      }
      if (!(this.storage = options.storage)) {
        this.storage = new KissmetricsStorage(options.key);
      }
      if (!(person = this.storage.get())) {
        this.storage.set(person = this.createID());
      }
      AnonKissmetricsClient.__super__.constructor.call(this, key, person);
    }

    AnonKissmetricsClient.prototype.createID = function() {
      var parts, x;

      parts = (function() {
        var _i, _results;

        _results = [];
        for (x = _i = 0; _i <= 10; x = ++_i) {
          _results.push((((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1));
        }
        return _results;
      })();
      return parts.join('');
    };

    return AnonKissmetricsClient;

  })(KissmetricsClient);

  global.AnonKissmetricsClient = AnonKissmetricsClient;

}).call(this);
