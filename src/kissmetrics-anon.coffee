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


  # #### Clear
  # ----------

  # Clear data from localStorage.

  clear: ->
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


  # #### Clear
  # ----------

  # Clear a cookie.

  clear: ->
    Cookie.set @key, '', {expires: -1}


# ## Anon Kissmetrics Client
# --------------------------

# Wrapper for interacting with the Kissmetrics API with logged out users. The
# only difference from `KissmetricsClient` is that an identifier for the user
# will be automatically created and saved in their browser.
#
# ##### Arguments
#
# `apiKey` (String): Your Kissmetrics API key
#
# `options` *Optional* (Object):
#
#  * `storage`: Specify which internal engine you want to
#    use: `'localStorage'` or `'cookie'`. Default is `'localStorage'`
#  * `storageKey`: Specify what key you want the assigned ID to be
#    stored under. Default is `'kissmetricsAnon'`
#
# ```
# km = new AnonKissmetricsClient(API_KEY, {
#   storage: 'cookie',
#   storageKey: 'myKissmetricsAnon'
# })
# km.record('Visited signup form')
# ```

class AnonKissmetricsClient extends KissmetricsClient
  constructor: (apiKey, options = {}) ->
    @_storage =
      switch options.storage
        when 'cookie' then Cookie
        when 'localStorage' then LocalStorage
        else window.localStorage ? LocalStorage : Cookie

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
  # `newIdentity` (String): A new identifier to map to the `@person` set on
  # the current instance.
  #
  # `deleteStoredID` *Optional* (Boolean): Whether or not to delete the
  #   logged-out identity that was stored. Default `true`.
  #
  # ```
  # km.alias('evan+otheremail@example.com', false)
  # km.alias('evan+newemail@example.com')
  # ```

  alias: (newIdentity, deleteStoredID = true) ->
    @_storage.clear() unless deleteStoredID is off
    super newIdentity


# ## Exports
# ----------

# Make `AnonKissmetricsClient` available as a property
# on the current context in the browser.

@AnonKissmetricsClient = AnonKissmetricsClient unless NODEJS is on
