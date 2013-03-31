ENV = if typeof exports isnt 'undefined' then 'node' else 'browser'

https = require 'https' if ENV is 'node'

httpRequest = (args) ->
	args.port ?= 80
	args.path ?= ''
	url        = "https://#{args.host}:#{args.port}/#{args.path}"

	if ENV is 'node'
		https.get url
	else
		(new Image()).src = url

	return url


class KissmetricsClient
	constructor: (@key, @person) ->
		@host = 'trk.kissmetrics.com'
		@port = 80
		@query_types =
			record : 'e'
			set    : 's'
			alias  : 'a'


	record: (action, properties = {}) ->
		properties._n = action
		@generateQuery 'record', properties

	set: (properties) ->
		# Each property has to be sent in its own query
		for name, value of properties
			data = {}
			data[name] = value
			@generateQuery 'set', data

	alias: (to) ->
		@generateQuery 'alias', _n: to

	generateQuery: (type, data) ->
		data._k = @key
		data._p = @person

		queryParts = []
		for key, val of data
			queryParts.push "#{encodeURIComponent(key)}=#{encodeURIComponent(val)}"

		queryString = queryParts.join '&'

		@request "#{@query_types[type]}?#{queryString}"

	request: (endpoint) ->
		httpRequest
			host : @host
			port : @port
			path : endpoint

if ENV is 'node'
	exports.KissmetricsClient = KissmetricsClient
else
	@KissmetricsClient = KissmetricsClient
