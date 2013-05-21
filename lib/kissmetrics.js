/**
 * Kissmetrics JS
 * https://github.com/evansolomon/kissmetrics-js
 * Copyright (c) 2013
 * Evan Solomon; Licensed MIT
 */

//@ sourceMappingURL=kissmetrics.map
(function() {
  var AnonKissmetricsClient, Cookie, KissmetricsClient, LocalStorage, NODEJS, https,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  NODEJS = typeof exports !== 'undefined';

  if (NODEJS === true) {
    https = require('https');
  }

  KissmetricsClient = (function() {
    KissmetricsClient.HOST = 'trk.kissmetrics.com';

    KissmetricsClient.QUERY_TYPES = {
      record: 'e',
      set: 's',
      alias: 'a'
    };

    function KissmetricsClient(apiKey, person, options) {
      var BatchClient;

      this.apiKey = apiKey;
      this.person = person;
      if (options == null) {
        options = {};
      }
      this.queries = [];
      if (NODEJS === true && options.queue) {
        BatchClient = require('./kissmetrics-batch');
        this.batchClient = new BatchClient(options.queue);
      }
    }

    KissmetricsClient.prototype.record = function(action, properties) {
      if (properties == null) {
        properties = {};
      }
      properties._n = action;
      return this._generateQuery('record', properties);
    };

    KissmetricsClient.prototype.set = function(properties) {
      delete properties._n;
      return this._generateQuery('set', properties);
    };

    KissmetricsClient.prototype.alias = function(to) {
      var _return;

      _return = this._generateQuery('alias', {
        _n: to
      });
      this.person = to;
      return _return;
    };

    KissmetricsClient.prototype._httpsRequest = function(args) {
      var url;

      url = "https://" + args.host + "/" + (args.path || '');
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
        if (!this.batchClient) {
          throw new Error('API key required');
        }
      }
      if (this.person) {
        return data._p = this.person;
      } else {
        throw new Error('Person required');
      }
    };

    KissmetricsClient.prototype._generateQuery = function(type, data) {
      var batchData, key, param, queryParts, queryString, queryType, val;

      this._validateData(data);
      if (this.batchClient) {
        batchData = data;
        batchData.__type = type;
        this.batchClient.add(batchData);
      } else {
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
        queryType = KissmetricsClient.QUERY_TYPES[type];
        this.queries.push(this._httpsRequest({
          host: KissmetricsClient.HOST,
          path: "" + queryType + "?" + queryString
        }));
      }
      return this;
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
      this._storage = (function() {
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
      this._storage.key = options.storageKey || 'kissmetricsAnon';
      if (!(person = this._storage.get())) {
        person = this.createID();
        this._storage.set(person);
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

    AnonKissmetricsClient.prototype.alias = function(to, deleteStoredID) {
      if (deleteStoredID == null) {
        deleteStoredID = true;
      }
      if (deleteStoredID !== false) {
        this._storage["delete"]();
      }
      return AnonKissmetricsClient.__super__.alias.call(this, to);
    };

    return AnonKissmetricsClient;

  })(KissmetricsClient);

  if (NODEJS !== true) {
    this.AnonKissmetricsClient = AnonKissmetricsClient;
  }

}).call(this);
