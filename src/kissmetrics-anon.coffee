# # Kissmetrics Anon
# ------------------


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
