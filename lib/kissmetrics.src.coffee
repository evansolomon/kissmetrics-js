# # Kissmetrics JS

# ## Bootstrap
# -------------

# Keep track of what environment we're running in, Node.js or a browser.

NODEJS = typeof exports isnt 'undefined'


# If we're in Node, require the `https` module for our network requests.
#
# If we're in a browser we'll just use the implicit requests generated by
# `Image().src`. Kissmetrics responds to API requests with an `image/gif`
# content type, so the browser won't throw up any warnings.

https = require 'https' if NODEJS is on


# ## HTTP Request
# ---------------

# Generic wrapper for HTTP requests that abstracts the differences between
# requests made in Node and in a browser.

httpRequest = (args) ->
  # Node.js 0.6 had a different API syntax for the HTTP module
  # If we're using ~0.6, pass the args straight away

  return https.get args if NODEJS is on and process.version.match /^v0\.6/

  # If we're in a browser or later version of node, form a URL
  args.path ?= ''
  url = "https://#{args.host}/#{args.path}"

  if NODEJS is on then https.get url else (new Image()).src = url


# ## Kissmetrics Client
# ---------------------

# Wrapper for interacting with the Kissmetrics API.
#
# Instantiates a new client with your Kissmetrics API key and an identifier
# for the person you're recording data about. A new client must be created
# for each person you record data about.
#
# All data methods (`record`, `set`, `alias`) are chainable.
#
# ```
# km = new KissmetricsClient(API_KEY, user);
# km.record('Changed username')
#   .alias(user.newname)
#   .set({mood: 'indecisive'});
# ```
#
# ##### Arguments
#
# `apiKey` (String): Your API key from Kissmetrics
#
# `person` (String): An identifier for the person you'll record data about
#
# ```
# km = new KissmetricsClient(API_KEY, 'evan@example.com')
# ```

class KissmetricsClient
  constructor: (@apiKey, @person) ->
    @host       = 'trk.kissmetrics.com'
    @queryTypes =
      record : 'e'
      set    : 's'
      alias  : 'a'


  # ### Record
  # ----------

  # Record an "event" in Kissmetrics.
  #
  # http://support.kissmetrics.com/apis/common-methods#record
  #
  # ##### Arguments
  #
  # `action` (String): Name of the event you're recording. This is
  #   usually something a person did or something that affects them.
  #
  # `properties` *Optional* (Object): Properties to associate with
  #   the person's event. Keys will be used as property names and values
  #   as property values.
  #
  # ```
  # km.record('Signed up', {page: 'home'})
  # ```

  record: (action, properties = {}) ->
    properties._n = action
    @_generateQuery 'record', properties
    return @


  # ### Set
  # -------

  # Set a "property" in Kissmetrics.
  #
  # http://support.kissmetrics.com/apis/common-methods#set
  #
  # ##### Arguments
  #
  # `properties` (Object): Properties to associate with the person. Keys
  #   will be used as property names and values as property values.
  #
  # This behaves exactly like the `properties` argument in `record`, except
  # it includes an additional safety check to make sure you don't use the
  # reserved `_n` property name.
  #
  # ```
  # km.set({location: 'San Francisco', gender: 'male'})
  # ```

  set: (properties) ->
    delete properties._n

    @_generateQuery 'set', properties
    return @


  # ### Alias
  # ---------

  # Alias a person to another "identity" in Kissmetrics. Updates the current
  # instance's `person` attribute to the new identity.
  #
  # http://support.kissmetrics.com/apis/common-methods#alias
  #
  # ##### Arguments
  #
  # `to` (String): A new identifier to map to the `@person` set on
  # the current instance.
  #
  # ```
  # km.alias('evan+newemail@example.com')
  # ```

  alias: (to) ->
    @_generateQuery 'alias', _n: to
    @person = to
    return @


  # ### Generate Query
  # #### (Private)
  # ------------------

  # Prepare data to be sent to Kissmetrics by turning it into a URL path
  # and query string. Once the query is formed, call `record()` to send
  # it to Kissmetrics.
  #
  # Automatically prevents any Kissmetrics-reserved keys from being
  # accidentally used for properties.
  #
  # http://support.kissmetrics.com/apis/specifications.html
  #
  # ##### Arguments
  #
  # * `type` (String): Type of data being sent (`record`, `set` or `alias`).
  #
  # * `data` (Object): Specific data being recorded about this person.

  _generateQuery: (type, data) ->
    return false unless @apiKey and @person

    data._k = @apiKey
    data._p = @person

    reservedKeys = ['_t', '_d']

    queryParts = for key, val of data
      continue if reservedKeys.indexOf(key) > -1

      [key, val] = (encodeURIComponent param for param in [key, val])
      "#{key}=#{val}"

    queryString = queryParts.join '&'
    @lastQuery = @_request "#{@queryTypes[type]}?#{queryString}"


  # ### Request
  # #### (Private)
  # --------------

  # Query the Kissmetrics API
  #
  # ##### Arguments
  #
  # `endpoint` (String): URL path (without a leading slash) that will be used
  #   as a Kissmetrics API endpoint.

  _request: (endpoint) ->
    httpRequest
      host: @host
      path: endpoint


# ### Exports
# -----------

# Make `KissmetricsClient` available either as a Node module or a property
# on the current context in the browser.
#
# ```
# // Node.js
# KM = require('kissmetrics')
# kmClient = new KM('apiKey', 'evan')
# ```
#
# ```
# // Browser
# kmClient = new window.KissmetricsClient('apiKey', 'evan')
# ```

if NODEJS is on
  module.exports = KissmetricsClient
else
  @KissmetricsClient = KissmetricsClient

# # Kissmetrics Anon

# ## Storage
# ----------
# Inspired by store.js
#
# https://github.com/deleteme/store


# ### Local Storage
# -----------------

# Interacts with HTML5's `localStorage`.

LocalStorage =


  # #### Get
  # --------

  # Retrieve data from localStorage.
  #
  # ##### Arguments
  #
  # `key` (String)

  get: (key) ->
    window.localStorage.getItem key


  # #### Set
  # --------

  # Save data to localStorage.
  #
  # ##### Arguments
  #
  # `key` (String)
  #
  # `value` (String)

  set: (key, value) ->
    window.localStorage.setItem key, value


  # #### Delete
  # -----------

  # Delete data from localStorage.
  #
  # ##### Arguments
  #
  # `key` (String)

  delete: (key) ->
    window.localStorage.removeItem key


# ### Cookies
# -----------

# Interacts with the browser's cookies.

Cookie =


  # #### Get
  # --------

  # Retrieve data from cookies.
  #
  # ##### Arguments
  #
  # `key` (String)

  get: (key) ->
    key += '='
    for cookiePart in document.cookie.split ';'
      cleanedPart = cookiePart.replace(/^\s+/, '')
        .substring(key.length + 1, cookiePart.length)

      return cleanedPart if cleanedPart.indexOf key is 0


  # #### Set
  # --------

  # Save data to a cookie.
  #
  # ##### Arguments
  #
  # `name` (String)
  #
  # `value` (String)
  #
  # `options` (Object): Optional, only used for deleting cookies by writing
  #   them with an expiration time in the past.

  set: (name, value, options = {expires: ''}) ->
    unless options.expires
        date = new Date
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000))
        options.expires = "expires=" + date.toGMTString()

    document.cookie = "#{name}=#{value}; #{options.expires}; path=/"


  # #### Delete
  # -----------

  # Delete a cookie.
  #
  # ##### Arguments
  #
  # `key` (String)

  delete: (key) ->
    Cookie.set key, '', {expires: -1}


# ## Anon Kissmetrics Client
# --------------------------

# Wrapper for interacting with the Kissmetrics API with logged out users. The
# only difference from `KissmetricsClient` is that an identifier for thie user
# will be automatically created and saved in their browser.
#
# ##### Arguments
#
# `apiKey` (String): Your Kissmetrics API key
#
# `options` (Object): Optionally provide a key and storage engine
#
# ```
# km = new AnonKissmetricsClient(API_KEY)
# km.record('Visited signup form')
# ```

class AnonKissmetricsClient extends KissmetricsClient
  constructor: (apiKey, options = {}) ->
    @storage = switch options.storage
      when 'cookie' then Cookie
      when 'localStorage' then LocalStorage
      when null then (if window.localStorage? then LocalStorage else Cookie)
      else options.storage

    storageKey = options.storageKey || 'kissmetricsAnon'

    unless person = @storage.get storageKey
      @storage.set(storageKey, person = @createID())

    super apiKey, person


  # ### Create ID
  # -------------

  # Create a persistent ID for an anonymous user.
  #
  # Inspired by http://stackoverflow.com/a/105074/30098
  createID: ->
    parts = for x in [0..10]
      (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

    parts.join ''


# ## Exports
# ----------

# Make `AnonKissmetricsClient` available as a property
# on the current context in the browser.

@AnonKissmetricsClient = AnonKissmetricsClient unless NODEJS is on
