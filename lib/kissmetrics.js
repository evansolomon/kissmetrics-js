/**
 * Kissmetrics JS
 * https://github.com/evansolomon/kissmetrics-js
 * Copyright (c) 2013
 * Evan Solomon; Licensed MIT
 */

//@ sourceMappingURL=kissmetrics.map
(function() {
  var AnonKissmetricsClient, Cookie, KissmetricsClient, KissmetricsStorage, LocalStorage, NODEJS, httpRequest, https,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  NODEJS = typeof exports !== 'undefined';

  if (NODEJS === true) {
    https = require('https');
  }

  httpRequest = function(args) {
    var url, _ref;

    if (NODEJS === true && process.version.match(/^v0\.6/)) {
      return https.get(args);
    }
    if ((_ref = args.path) == null) {
      args.path = '';
    }
    url = "https://" + args.host + "/" + args.path;
    if (NODEJS === true) {
      return https.get(url);
    } else {
      return (new Image()).src = url;
    }
  };

  KissmetricsClient = (function() {
    function KissmetricsClient(apiKey, person) {
      this.apiKey = apiKey;
      this.person = person;
      this.host = 'trk.kissmetrics.com';
      this.queryTypes = {
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
      this._generateQuery('record', properties);
      return this;
    };

    KissmetricsClient.prototype.set = function(properties) {
      delete properties._n;
      this._generateQuery('set', properties);
      return this;
    };

    KissmetricsClient.prototype.alias = function(to) {
      this._generateQuery('alias', {
        _n: to
      });
      this.person = to;
      return this;
    };

    KissmetricsClient.prototype._generateQuery = function(type, data) {
      var key, param, queryParts, queryString, reservedKeys, val;

      if (!(this.apiKey && this.person)) {
        return false;
      }
      data._k = this.apiKey;
      data._p = this.person;
      reservedKeys = ['_t', '_d'];
      queryParts = (function() {
        var _ref, _results;

        _results = [];
        for (key in data) {
          val = data[key];
          if (reservedKeys.indexOf(key) > -1) {
            continue;
          }
          _ref = (function() {
            var _i, _len, _ref, _results1;

            _ref = [key, val];
            _results1 = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              param = _ref[_i];
              _results1.push(encodeURIComponent(param));
            }
            return _results1;
          })(), key = _ref[0], val = _ref[1];
          _results.push("" + key + "=" + val);
        }
        return _results;
      })();
      queryString = queryParts.join('&');
      return this.lastQuery = this._request("" + this.queryTypes[type] + "?" + queryString);
    };

    KissmetricsClient.prototype._request = function(endpoint) {
      return httpRequest({
        host: this.host,
        path: endpoint
      });
    };

    return KissmetricsClient;

  })();

  if (NODEJS === true) {
    module.exports = KissmetricsClient;
  } else {
    this.KissmetricsClient = KissmetricsClient;
  }

  LocalStorage = {
    get: function(key) {
      return window.localStorage.getItem(key);
    },
    set: function(key, value) {
      return window.localStorage.setItem(key, value);
    },
    "delete": function(key) {
      return window.localStorage.removeItem(key);
    }
  };

  Cookie = {
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

    KissmetricsStorage.prototype.get = function() {
      return this.store.get(this.key);
    };

    KissmetricsStorage.prototype.set = function(value) {
      return this.store.set(this.key, value);
    };

    KissmetricsStorage.prototype["delete"] = function() {
      return this.store["delete"](this.key);
    };

    return KissmetricsStorage;

  })();

  AnonKissmetricsClient = (function(_super) {
    __extends(AnonKissmetricsClient, _super);

    function AnonKissmetricsClient(apiKey, options) {
      var person;

      if (options == null) {
        options = {
          storageKey: 'kissmetricsAnon'
        };
      }
      if (!(this.storage = options.storage)) {
        this.storage = new KissmetricsStorage(options.storageKey);
      }
      if (!(person = this.storage.get())) {
        this.storage.set(person = this.createID());
      }
      AnonKissmetricsClient.__super__.constructor.call(this, apiKey, person);
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

  if (NODEJS !== true) {
    this.AnonKissmetricsClient = AnonKissmetricsClient;
  }

}).call(this);
