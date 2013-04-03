# # Kissmetrics JS

# ## Bootstrap
# -------------

# Keep track of what environment we're running in, Node.js or a browser.
#
# If we're in Node.js, also record whether or not it's version 0.6 so that
# we can suppor its legacy API.

NODEJS    = typeof exports isnt 'undefined'
NODEJS_06 = NODEJS is on and process.version.match /^v0\.6/


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


  # ## HTTPS Request
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
    # Node.js 0.6 had a different API syntax for the HTTPS module.
    # If we're using ~0.6, pass the args straight away.

    return https.get args if NODEJS_06 is on

    # If we're in a browser or later version of node, form a URL
    args.path ?= ''
    url = "https://#{args.host}/#{args.path}"

    if NODEJS is on then https.get url else (new Image()).src = url


  # ### Validate Data
  # #### (Private)
  # ------------------

  # Automatically prevents any Kissmetrics-reserved keys from being
  # accidentally used for properties. Throws an `Error` when required
  # attributes (`apiKey` or `person`) are missing.
  #
  # Ensures that reserved keys that are used (`_k` for API key and `_p`
  # for person) are set correctly, regardless of whether they were in the
  # original data.
  #
  # http://support.kissmetrics.com/apis/specifications.html
  #
  # ##### Arguments
  #
  # * `data` (Object): Specific data being recorded about this person.

  _validateData: (data) ->
    throw new Error 'API key required' unless @apiKey
    throw new Error 'Person required' unless @person

    delete data[reservedKey] for reservedKey in ['_t', '_d']

    data._k = @apiKey
    data._p = @person


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

    @lastQuery = @_httpsRequest
      host: @host
      path: "#{@queryTypes[type]}?#{queryString}"


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
