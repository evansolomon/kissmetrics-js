should = require 'should'
KM     = require '../src/kissmetrics'

describe 'KM module', ->
	it 'should exist', ->
		should.exist KM

describe 'KM instance', ->
	it 'should initialize', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.apiKey.should.equal 'apiKey'
		km.person.should.equal 'evan@example.com'

	it 'should be instance of KissmetricsClient', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.should.be.an.instanceOf KM

	it 'should have API methods', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.should.have.property 'record'
		km.should.have.property 'set'
		km.should.have.property 'alias'

describe 'Record', ->
	it 'should record events', ->
		expectedOutput = /^GET \/?e\?_n=test%20event&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.record('test event').lastQuery.output.pop().match(expectedOutput).should.be.ok

describe 'Set', ->
	it 'should set properties', ->
		expectedOutput = /GET \/?s\?place=home&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.set({place: 'home'}).lastQuery.output.pop().match(expectedOutput).should.be.ok

	it 'should set multiple properties', ->
		expectedOutput = /GET \/?s\?place=home&otherPlace=work&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.set({place: 'home', otherPlace: 'work'}).lastQuery.output.pop().match(expectedOutput).should.be.ok

	it 'should block reserved keys', ->
		expectedOutput = /GET \/?s\?foo=Safe&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.set({foo: 'Safe', _n: 'Blocked'}).lastQuery.output.pop().match(expectedOutput).should.be.ok

describe 'Alias', ->
	it 'should alias people', ->
		expectedOutput  = /GET \/?a\?_n=notevan%40example.com&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.alias('notevan@example.com').lastQuery.output.pop().match(expectedOutput).should.be.ok

	it 'should change person on alias', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.alias 'someone@example.com'
		km.person.should.be.equal 'someone@example.com'

describe 'Client API', ->
	it 'should be chainable', ->
		expectedOutput  = /GET \/?a\?_n=notevan%40example.com&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.record('foo').alias('notevan@example.com').lastQuery.output.pop().match(expectedOutput).should.be.ok

	it 'should require apiKey', ->
		km = new KM 'apiKey', 'evan@example.com'
		delete km.apiKey

		lastQuery = km.record('foo')
		lastQuery.should.not.exist

	it 'should require person', ->
		km = new KM 'apiKey', 'evan@example.com'
		delete km.person

		lastQuery = km.record('foo')
		lastQuery.should.not.exist
