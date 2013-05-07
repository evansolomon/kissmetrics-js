# # Kissmetrics JS

# ## Bootstrap
# -------------

# Keep track of what environment we're running in, Node.js or a browser.

NODEJS    = typeof exports isnt 'undefined'


# If we're in Node, require the `https` module for our network requests.
#
# If we're in a browser we'll just use the implicit requests generated by
# `Image().src`. Kissmetrics responds to API requests with an `image/gif`
# content type, so the browser won't throw up any warnings.

https = require 'https' if NODEJS is on


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
    @queries    = []
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
    _return = @_generateQuery 'alias', _n: to
    @person = to
    return _return


  # ### HTTPS Request
  # #### (Private)
  # ---------------

  # Generic wrapper for HTTPS requests that abstracts the differences between
  # requests made in Node and in a browser.
  #
  # ##### Arguments
  #
  # * `args` (Object): Key value pairs of URL pieces; only `host` and
  #   `path` are used, and `host` is required.

  _httpsRequest: (args) ->

    # If we're in a browser or later version of node, form a URL
    args.path ?= ''
    url = "https://#{args.host}/#{args.path}"

    if NODEJS is on then https.get url else (new Image()).src = url


  # ### Validate Data
  # #### (Private)
  # ------------------

  # Ensures that reserved keys that are used (`_k` for API key and `_p`
  # for person) are present and set correctly, regardless of whether they
  # were in the original data.
  #
  # http://support.kissmetrics.com/apis/specifications.html
  #
  # ##### Arguments
  #
  # * `data` (Object): Specific data being recorded about this person.

  _validateData: (data) ->
    if @apiKey then data._k = @apiKey else throw new Error 'API key required'
    if @person then data._p = @person else throw new Error 'Person required'


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
    @_validateData data

    queryParts = for key, val of data
      [key, val] = (encodeURIComponent param for param in [key, val])
      "#{key}=#{val}"

    queryString = queryParts.join '&'

    @queries.push @_httpsRequest
      host: @host
      path: "#{@queryTypes[type]}?#{queryString}"

    return @


# ## Exports
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

  get: ->
    window.localStorage.getItem @key


  # #### Set
  # --------

  # Save data to localStorage.
  #
  # ##### Arguments
  #
  # `value` (String)

  set: (value) ->
    window.localStorage.setItem @key, value


  # #### Delete
  # -----------

  # Delete data from localStorage.

  delete: ->
    window.localStorage.removeItem @key


# ### Cookies
# -----------

# Interacts with the browser's cookies.

Cookie =


  # #### Get
  # --------

  # Retrieve data from cookies.

  get: ->
    key = "#{@key}="
    for cookiePart in document.cookie.split /;\s*/
      if cookiePart.indexOf(key) is 0
        return cookiePart.substring key.length


  # #### Set
  # --------

  # Save data to a cookie.
  #
  # ##### Arguments
  #
  # `value` (String)
  #
  # `options` *Optional* (Object): Only used for deleting cookies by writing
  #   them with an expiration time in the past.

  set: (value, options = {expires: ''}) ->
    unless options.expires
        date = new Date
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000))
        options.expires = "expires=" + date.toGMTString()

    document.cookie = "#{@key}=#{value}; #{options.expires}; path=/"


  # #### Delete
  # -----------

  # Delete a cookie.

  delete: ->
    Cookie.set @key, '', {expires: -1}


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
# `options` *Optional* (Object): Provide a key and/or storage engine, or
#   specif which internal engine you want to use: `'localStorage'` or
#   `'cookie'`.
#
# If you provide your own storage engine, it **must** match the
# API's provided by `Cookie` and `LocalStorage` with `get()`, `set()` and
# `delete()` methods. All methods should use `this.storageKey` to reference
# the key to retreive data by, and `set()` must accept a key and value. The
# methods will always be called in the correct context by the API, such
# that `this.storageKey` will be available.
#
# ```
# km = new AnonKissmetricsClient(API_KEY)
# km.record('Visited signup form')
# ```

class AnonKissmetricsClient extends KissmetricsClient
  constructor: (apiKey, options = {}) ->
    options.storage ?= null

    @_storage =
      if options.storage
        switch options.storage
          when 'cookie' then Cookie
          when 'localStorage' then LocalStorage
          else options.storage
      else
        if window.localStorage? then LocalStorage else Cookie

    @_storage.key = options.storageKey || 'kissmetricsAnon'

    unless person = @_storage.get()
      person = @createID()
      @_storage.set person

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


  # ### Alias
  # ---------

  # Identify the current user and (by default) delete the logged out
  # identifier that was stored.
  #
  # ##### Arguments
  #
  # `to` (String): A new identifier to map to the `@person` set on
  # the current instance.
  #
  # `deleteStoredID` *Optional* (Boolea): Whether or not to delete the
  #   logged-out identity that was stored. Default `true`.
  #
  # ```
  # km.alias('evan+otheremail@example.com', false)
  # km.alias('evan+newemail@example.com')
  # ```

  alias: (to, deleteStoredID = true) ->
    @_storage.delete() unless deleteStoredID is off
    super to


# ## Exports
# ----------

# Make `AnonKissmetricsClient` available as a property
# on the current context in the browser.

@AnonKissmetricsClient = AnonKissmetricsClient unless NODEJS is on
