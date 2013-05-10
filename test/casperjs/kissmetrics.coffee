# The page doesn't actually matter
casper.start 'http://localhost:9000/index.html'

casper.then ->
	# Injections are relative to the project root
	casper.page.injectJs 'min/kissmetrics.min.js'



# Existance
casper.then ->
	KM = @evaluate ->
		!! window.KissmetricsClient

	@test.assertTruthy KM, 'KissmetricsClient exists'



# Instantiation
casper.then ->
	km = @evaluate ->
		new KissmetricsClient 'abc123', 'evan'

	@test.assertEquals km.person, 'evan', 'Person is set correctly'
	@test.assertEquals km.apiKey, 'abc123', 'API key is set correctly'

casper.then ->
	instanceOfKM = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km instanceof KissmetricsClient

	@test.assertTruthy instanceOfKM, 'km is instance of KissmetricsClient'



# Record
casper.then ->
	exepectedQuery = 'https://trk.kissmetrics.com/e?_n=event%20name&_k=abc123&_p=evan'
	lastQuery = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.record('event name').queries.pop()

	@test.assertEquals lastQuery, exepectedQuery, 'Records event'



# Set
casper.then ->
	exepectedQuery = 'https://trk.kissmetrics.com/s?place=home&_k=abc123&_p=evan'
	lastQuery = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.set({place: 'home'}).queries.pop()

	@test.assertEquals lastQuery, exepectedQuery, 'Sets properties'

casper.then ->
	exepectedQuery = 'https://trk.kissmetrics.com/s?place=home&foo=bar&_k=abc123&_p=evan'
	lastQuery = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.set({place: 'home', foo: 'bar'}).queries.pop()

	@test.assertEquals lastQuery, exepectedQuery, 'Sets multiple properties'


# Alias
casper.then ->
	exepectedQuery = 'https://trk.kissmetrics.com/a?_n=notevan&_k=abc123&_p=evan'
	lastQuery = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.alias('notevan').queries.pop()

	@test.assertEquals lastQuery, exepectedQuery, 'Alias person'

casper.then ->
	km = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.alias 'notevan'

	@test.assertEquals km.person, 'notevan', 'Updates person attribute'


# Query log
casper.then ->
	queries = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.record('event name').set({foo: 'bar'}).queries

	@test.assertEquals 2, queries.length, 'Logs all queries'

casper.then ->
	queries = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		firstLoggedQuery = km.record('event name').queries[0]
		km.record('foo')
		{first: firstLoggedQuery, all: km.queries}

	@test.assertEquals queries.first, queries.all[0], 'Logs queries in order'


# Client API
casper.then ->
	ownInstance = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.record('event name') instanceof KissmetricsClient

	@test.assertTruthy ownInstance, 'KissmetricsClient returns its own instance'

casper.then ->
	exepectedQuery = 'https://trk.kissmetrics.com/e?_n=other%20event%20name&_k=ab&_p=evan'
	lastQuery = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		km.record('event name').record('other event name').queries.pop()

	@test.assertTruthy lastQuery, 'Runs multiple queries when chained'

casper.then ->
	kmRecord = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		delete km.apiKey
		km.record

	@test.assertRaises kmRecord, ['event name'], 'Requires API key'

casper.then ->
	kmRecord = @evaluate ->
		km = new KissmetricsClient 'abc123', 'evan'
		delete km.person
		km.record

	@test.assertRaises kmRecord, ['event name'], 'Requires Person'

casper.run ->
	@test.done()
