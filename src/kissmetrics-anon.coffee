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
  #g
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
# `options` (Object): Optionally provide a key and storage engine, or specify
#   which internal engine you want to use: `'localStorage'` or `'cookie'`. If
#   you provide your own storage engine, it **must** match the API's provided
#   by `Cookie` and `LocalStorage` with `get()`, `set()` and `delete()`
#   methods. The `get()` and `delete()` methods must accept a key, and `set()`
#   must accept a key and value.
#
# ```
# km = new AnonKissmetricsClient(API_KEY)
# km.record('Visited signup form')
# ```

class AnonKissmetricsClient extends KissmetricsClient
  constructor: (apiKey, options = {}) ->
    options.storage ?= null

    @storage =
      if options.storage
        switch options.storage
          when 'cookie' then Cookie
          when 'localStorage' then LocalStorage
          else options.storage
      else
        if window.localStorage? then LocalStorage else Cookie

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
