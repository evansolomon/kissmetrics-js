# # Kissmetrics JS

# ## Bootstrap
# -------------

# Keep track of what environment we're running in, Node.js or a browser.

NODEJS = typeof exports isnt 'undefined'


# If we're in Node, require the `http` module for our network requests.
#
# If we're in a browser we'll just use the implicit requests generated by
# `Image().src`. Kissmetrics responds to API requests with an `image/gif`
# content type, so the browser won't throw up any warnings.

http = require 'http' if NODEJS is on


# ## HTTP Request
# ------------

# Generic wrapper for HTTP requests that abstracts the differences between
# requests made in Node and in a browser.

httpRequest = (url) ->
  if NODEJS is on then http.get url else (new Image()).src = url


# ## Kissmetrics Client
# --------------------

# Wrapper for interacting with the Kissmetrics API.
#
# Instantiates a new client with your Kissmetrics API key and an identifier
# for the person you're recording data about. A new client must be created
# for each person you record data about.
#
# ##### Arguments
#
# `key` (String): Your API key from Kissmetrics
#
# `person` (String): An identifier for the person you'll record data about
#
# ```
# km = new KissmetricsClient(API_KEY, 'evan@example.com')
# ```

class KissmetricsClient
  constructor: (@key, @person) ->
    @host        = 'trk.kissmetrics.com'
    @port        = 80
    @query_types =
      record : 'e'
      set    : 's'
      alias  : 'a'


  # ### Record
  # ----------

  # Record an "event" in Kissmetrics.
  # http://support.kissmetrics.com/apis/common-methods#record
  #
  # ##### Arguments
  #
  # `action` (String): Name of the event you're recording. This is
  #   usually something a person did or something that affects them.
  #
  # `properties` (Object) *Optional*: Properties to associate with
  #   the person's event. Keys will be used as property names and values
  #   as property values.
  #
  # ```
  # km.record('Signed up', {page: 'home'})
  # ```

  record: (action, properties = {}) ->
    properties._n = action
    @_generateQuery 'record', properties


  # ### Set
  # -------

  # Set a "property" in Kissmetrics.
  # http://support.kissmetrics.com/apis/common-methods#set
  #
  # ##### Arguments
  #
  # `properties` (Object): Properties to associate with
  #   the person's event. Keys will be used as property names and values
  #   as property values.
  #
  # This behaves exactly like the `properties` argument in `record` except
  # that it is required and that each property has to be sent in its own query.
  #
  # ```
  # km.set({location: 'San Francisco', gender: 'male'})
  # ```

  set: (properties) ->
    for name, value of properties
      data       = {}
      data[name] = value
      @_generateQuery 'set', data


  # ### Alias
  # ---------

  # Alias a person to another "identity" in Kissmetrics.
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


  # ### Generate Query
  # #### (Private)
  # ------------------

  # Prepare data to be sent to Kissmetrics by turning it into a URL path
  # and query string. Once the query is formed, call `record()` to send
  # it to Kissmetrics.
  #
  # ##### Arguments
  #
  # * `type` (String): Type of data being sent (`record`, `set` or `alias`).
  #
  # * `data` (Object): Specific data being recorded about this person.

  _generateQuery: (type, data) ->
    data._k = @key
    data._p = @person

    queryParts = for key, val of data
      key = encodeURIComponent key
      val = encodeURIComponent val
      "#{key}=#{val}"

    queryString = queryParts.join '&'

    @_request "#{@query_types[type]}?#{queryString}"


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
    httpRequest "http://#{@host}:#{@port}/#{endpoint}"


# ### Exports
# -----------

# Make `KissmetricsClient` available either as a Node module or a property
# on the current context in the browser.
#
# ```
# // Node.js
# KM = require('kissmetrics')
# kmClient = new KM.KissmetricsClient('apiKey', 'evan')
# ```
#
# ```
# // Browser
# kmClient = new window.KissmetricsClient('apiKey', 'evan')
# ```

global = if NODEJS is on then exports else @
global.KissmetricsClient = KissmetricsClient

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


  # #### Set
  # -------

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
  # -------

  # Delete data from localStorage.
  #
  # ##### Arguments
  #
  # `key` (String)

  delete: (key) ->
    window.localStorage.removeItem key


  # #### Get
  # -------

  # Retrieve data from localStorage.
  #
  # ##### Arguments
  #
  # `key` (String)

  get: (key) ->
    window.localStorage.getItem key


# ### Cookies
# -----------------

# Interacts with the browser's cookies.

Cookie =


  # #### Set
  # -------

  # Save data to a cookie.
  #
  # ##### Arguments
  #
  # `key` (String)
  #
  # `value` (String)
  #
  # `options` (Object): Optional, only used for deleting cookies by writing
  #   them with an expiration time in the past.

  set: (key, value, options = {expires: ''}) ->
    unless options.expires
        date = new Date
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000))
        options.expires = "expires=" + date.toGMTString()

    document.cookie = "#{name}=#{value}; #{options.expires}; path=/"


  # #### Get
  # -------

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


  # #### Delete
  # -------

  # Delete a cookie.
  #
  # ##### Arguments
  #
  # `key` (String)

  delete: (key) ->
    Cookie.set key, '', {expires: -1}


# ## Kissmetrics Storage
# ----------------------

# Wrap the `get`, `set`, and `delete` methods and abstract the differences
# between the storage engines.  Local Storage will be used when available,
# and browser cookies will be used as a fallback.
#
# ##### Arguments
#
# `key` (String): The key to associate with the logged out identity. This is
#   *not* your Kissmetrics API key.

class KissmetricsStorage

  constructor: (@key) ->
    @store = if window.localStorage? then LocalStorage else Cookie


  # #### Set
  # -------

  # Save the user's identifier.
  #
  # ##### Arguments
  #
  # `value` (String): The logged out user identity.

  set: (value) ->
    @store.set @key, value


  # #### Get
  # -------

  # Retrieve the user's logged out identifier.

  get: ->
    @store.get @key


  # #### Delete
  # -------

  # Delete the user's logged out identifier.

  delete: ->
    @store.delete @key


# ## Anon Kissmetrics Client
# --------------------------

# Wrapper for interacting with the Kissmetrics API with logged out users. The
# only difference from `KissmetricsClient` is that an identifier for thie user
# will be automatically created and saved in their browser.
#
# ##### Arguments
#
# `key` (String): Your Kissmetrics API key
#
# `options` (Object): Optionally provide a key and storage engine
#
# ```
# km = new AnonKissmetricsClient(API_KEY)
# km.record('Visited signup form')
# ```

class AnonKissmetricsClient extends KissmetricsClient
  constructor: (key, options = {key: 'kissmetricsAnon'}) ->
    unless @storage = options.storage
      @storage = new KissmetricsStorage options.key

    @storage.set(person = @createID()) unless person = @storage.get()

    super key, person


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

# Make `AnonKissmetricsClient` available as a Node module or a property
# on the current context in the browser.

global.AnonKissmetricsClient = AnonKissmetricsClient
