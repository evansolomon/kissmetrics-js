/**
 * Kissmetrics JS
 * https://github.com/evansolomon/kissmetrics-js
 * Copyright (c) 2013
 * Evan Solomon; Licensed MIT
 */

//@ sourceMappingURL=kissmetrics.map
(function() {
  var AnonKissmetricsClient, Cookie, KissmetricsClient, LocalStorage, NODEJS, NODEJS_06, https,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  NODEJS = typeof exports !== 'undefined';

  NODEJS_06 = NODEJS === true && /^v0\.6/.test(process.version);

  if (NODEJS === true) {
    https = require('https');
  }

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

    KissmetricsClient.prototype._httpsRequest = function(args) {
      var url, _ref;

      if (NODEJS_06 === true) {
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

    KissmetricsClient.prototype._validateData = function(data) {
      if (this.apiKey) {
        data._k = this.apiKey;
      } else {
        throw new Error('API key required');
      }
      if (this.person) {
        return data._p = this.person;
      } else {
        throw new Error('Person required');
      }
    };

    KissmetricsClient.prototype._generateQuery = function(type, data) {
      var key, param, queryParts, queryString, val;

      this._validateData(data);
      queryParts = (function() {
        var _ref, _results;

        _results = [];
        for (key in data) {
          val = data[key];
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
      return this.lastQuery = this._httpsRequest({
        host: this.host,
        path: "" + this.queryTypes[type] + "?" + queryString
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
    get: function() {
      return window.localStorage.getItem(this.key);
    },
    set: function(value) {
      console.log(this.storageKey);
      return window.localStorage.setItem(this.key, value);
    },
    "delete": function() {
      return window.localStorage.removeItem(this.key);
    }
  };

  Cookie = {
    get: function() {
      var cookiePart, key, _i, _len, _ref;

      key = "" + this.key + "=";
      _ref = document.cookie.split(/;\s*/);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cookiePart = _ref[_i];
        if (cookiePart.indexOf(key) === 0) {
          return cookiePart.substring(key.length);
        }
      }
    },
    set: function(value, options) {
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
      return document.cookie = "" + this.key + "=" + value + "; " + options.expires + "; path=/";
    },
    "delete": function() {
      return Cookie.set(this.key, '', {
        expires: -1
      });
    }
  };

  AnonKissmetricsClient = (function(_super) {
    __extends(AnonKissmetricsClient, _super);

    function AnonKissmetricsClient(apiKey, options) {
      var person, _ref;

      if (options == null) {
        options = {};
      }
      if ((_ref = options.storage) == null) {
        options.storage = null;
      }
      this.storage = (function() {
        if (options.storage) {
          switch (options.storage) {
            case 'cookie':
              return Cookie;
            case 'localStorage':
              return LocalStorage;
            default:
              return options.storage;
          }
        } else {
          if (window.localStorage != null) {
            return LocalStorage;
          } else {
            return Cookie;
          }
        }
      })();
      this.storage.key = options.storageKey || 'kissmetricsAnon';
      if (!(person = this.storage.get())) {
        person = this.createID();
        this.storage.set(person);
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
