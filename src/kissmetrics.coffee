# # Kissmetrics JS

# ## Bootstrap
# -------------

# Keep track of what environment we're running in, Node.js or a browser.
# If we're in Node, require the `https` module for our network requests.
#
# If we're in a browser we'll just use the implicit requests generated by
# `Image`'s `src` property. Kissmetrics responds to API requests with an
# `image/gif` content type, so the browser won't throw up any warnings.
ENV = if typeof exports isnt 'undefined' then 'node' else 'browser'

https = require 'https' if ENV is 'node'


# ## HTTP Request
# ------------

# Generic wrapper for HTTP requests that abstracts the differences between
# requests made in Node and in a browser.
httpRequest = (url) ->
	if ENV is 'node'
		https.get url
	else
		(new Image()).src = url


# ## Kissmetrics Client
# --------------------

# Wrapper for interacting with the Kissmetrics API.
#
# Instantiates a new client with your Kissmetrics API key and an identifier
# for the person you're recording data about. A new client must be created
# for each person you record data about.
#
# `key` (String): Your API key from Kissmetrics
#
#	`person` (String): An identifier for the person you'll record data about
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
	# * `type` (String): Type of data being sent (`record`, `set` or `alias`).
	#
	# * `data` (Object): Specific data being recorded about this person.
	_generateQuery: (type, data) ->
		data._k = @key
		data._p = @person

		queryParts = []
		for key, val of data
			queryParts.push "#{encodeURIComponent(key)}=#{encodeURIComponent(val)}"

		queryString = queryParts.join '&'

		@_request "#{@query_types[type]}?#{queryString}"

	# ### Request
	# #### (Private)
	# --------------

	# Query the Kissmetrics API
	#
	# `endpoint` (String): URL path (without a leading slash) that will be used
	#   as a Kissmetrics API endpoint.
	_request: (endpoint) ->
		httpRequest "https://#{@host}:#{@port}/#{endpoint}"


# ### Exports
# -----------

# Make `KissmetricsClient` available either as a Node module or a property
# on the current context in the browser.
if ENV is 'node'
	exports.KissmetricsClient = KissmetricsClient
else
	@KissmetricsClient = KissmetricsClient
