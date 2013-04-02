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
# ---------------

# Generic wrapper for HTTP requests that abstracts the differences between
# requests made in Node and in a browser.

httpRequest = (args) ->
  # Node.js 0.6 had a different API syntax for the HTTP module
  # If we're using ~0.6, pass the args straight away

  return http.get args if NODEJS is on and process.version.match /^v0\.6/

  # If we're in a browser or later version of node, form a URL
  args.port ?= 80
  args.path ?= ''
  url = "http://#{args.host}:#{args.port}/#{args.path}"

  if NODEJS is on then http.get url else (new Image()).src = url


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
    @host        = 'trk.kissmetrics.com'
    @port        = 80
    @query_types =
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
    return @


  # ### Set
  # -------

  # Set a "property" in Kissmetrics.
  #
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
  # ##### Arguments
  #
  # * `type` (String): Type of data being sent (`record`, `set` or `alias`).
  #
  # * `data` (Object): Specific data being recorded about this person.

  _generateQuery: (type, data) ->
    data._k = @apiKey
    data._p = @person

    queryParts = for key, val of data
      key = encodeURIComponent key
      val = encodeURIComponent val
      "#{key}=#{val}"

    queryString = queryParts.join '&'

    @lastQuery = @_request "#{@query_types[type]}?#{queryString}"


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
      port: @port
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
