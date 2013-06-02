# The page doesn't actually matter
casper.start 'http://localhost:9000/index.html'

casper.then ->
	# Injections are relative to the project root
	casper.page.injectJs 'min/kissmetrics.min.js'


# Existance
casper.then ->
	KM = @evaluate ->
		!! window.AnonKissmetricsClient

	@test.assertTruthy KM, 'AnonKissmetricsClient exists'



# Instantiation
casper.then ->
	km = @evaluate ->
		new window.AnonKissmetricsClient 'abc123'

	@test.assertTruthy km.person, 'Identity is created'
	@test.assertEquals km.apiKey, 'abc123', 'API key is set correctly'

casper.then ->
	instanceOfKM = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		km instanceof AnonKissmetricsClient

	@test.assertTruthy instanceOfKM, 'km is instance of AnonKissmetricsClient'



# Auto-identifier storage
casper.then ->
	ID = @evaluate ->
		new window.AnonKissmetricsClient 'abc123'
		window.localStorage.getItem 'kissmetricsAnon'

	@test.assertTruthy ID, 'ID is stored in localStorage'

casper.then ->
	ID = @evaluate ->
		new window.AnonKissmetricsClient 'abc123', {storageKey: 'customKey'}
		window.localStorage.getItem 'customKey'

	@test.assertTruthy ID, 'ID is stored in localStorage with custom storage key'

casper.then ->
	data = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123', {storage: 'cookie'}
		{cookies: document.cookie, person: km.person}

	matchString = "kissmetricsAnon=#{data.person}"
	@test.assertTruthy data.cookies.match matchString, 'Cookie is saved'

casper.then ->
	data = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123',
			storage: 'cookie'
			storageKey: 'somethingCustom'
		{cookies: document.cookie, person: km.person}

	matchString = "somethingCustom=#{data.person}"
	@test.assertTruthy data.cookies.match matchString, 'Cookie is saved with custom storage key'

casper.then ->
	originalPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123', {storage: 'cookie'}
		km.person

	newPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123', {storage: 'cookie'}
		km.person

	@test.assertEquals originalPerson, newPerson, 'Person is persistent in cookies'

casper.then ->
	originalPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123',
			storage: 'cookie'
			storageKey: 'somethingCustom'

		km.person

	newPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123',
			storage: 'cookie'
			storageKey: 'somethingCustom'

		km.person

	@test.assertEquals originalPerson, newPerson, 'Person is persistent in cookies with custom storage key'

casper.then ->
	originalPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123', {storage: 'localStorage'}
		km.person

	newPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123', {storage: 'localStorage'}
		km.person

	@test.assertEquals originalPerson, newPerson, 'Person is persistent in localStorage'

casper.then ->
	originalPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123',
			storage: 'localStorage'
			storageKey: 'customKey'
		km.person

	newPerson = @evaluate ->
		km = new window.AnonKissmetricsClient 'abc123',
			storage: 'localStorage'
			storageKey: 'customKey'
		km.person

	@test.assertEquals originalPerson, newPerson, 'Person is persistent in localStorage with custom storage key'


# Record
casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123', 'evan'
		{person: km.person, query: km.record('event name').queries.pop()}

	exepectedQuery = "https://trk.kissmetrics.com/e?_n=event%20name&_k=abc123&_p=#{data.person}"
	@test.assertEquals data.query, exepectedQuery, 'Records event'



# Set
casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		{person: km.person, query: km.set({place: 'home'}).queries.pop()}

	exepectedQuery = "https://trk.kissmetrics.com/s?place=home&_k=abc123&_p=#{data.person}"
	@test.assertEquals data.query, exepectedQuery, 'Sets properties'

casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		{person: km.person, query: km.set({place: 'home', foo: 'bar'}).queries.pop()}

	exepectedQuery = "https://trk.kissmetrics.com/s?place=home&foo=bar&_k=abc123&_p=#{data.person}"
	@test.assertEquals data.query, exepectedQuery, 'Sets multiple properties'


# Alias
casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		{person: km.person, query: km.alias('notevan').queries.pop()}

	exepectedQuery = "https://trk.kissmetrics.com/a?_n=notevan&_k=abc123&_p=#{data.person}"
	@test.assertEquals data.query, exepectedQuery, 'Alias person'

casper.then ->
	km = @evaluate ->
		km = new AnonKissmetricsClient 'abc123', 'evan'
		km.alias 'notevan'

	@test.assertEquals km.person, 'notevan', 'Updates person attribute'

casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		km.alias 'username'
		km._storage.get()

	@test.assertFalsy data, 'Logged out ID is deleted by alias'

casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		km.alias 'username', false
		km._storage.get()

	@test.assertTruthy data, 'Logged out ID is retained by alias with the `false` argument'


# # Client API
casper.then ->
	ownInstance = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		km.record('event name') instanceof AnonKissmetricsClient

	@test.assertTruthy ownInstance, 'AnonKissmetricsClient returns its own instance'

casper.then ->
	data = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		{person: km.person, query: km.record('event name').record('other event name').queries.pop()}

	exepectedQuery = "https://trk.kissmetrics.com/e?_n=other%20event%20name&_k=ab&_p=#{data.person}"
	@test.assertTruthy data.query, 'Runs multiple queries when chained'

casper.then ->
	lastQuery = @evaluate ->
		km = new AnonKissmetricsClient 'abc123'
		delete km.apiKey
		km.record('event name').queries.pop()

	@test.assertFalsy lastQuery, 'Requires API key'

casper.then ->
	lastQuery = @evaluate ->
		km = new AnonKissmetricsClient
		delete km.person
		km.record('event name').queries.pop()

	@test.assertFalsy lastQuery, 'Requires Person'

casper.run ->
	@test.done()
