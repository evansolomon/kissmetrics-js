should = require 'should'
KM     = require '../../src/kissmetrics'

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
		km.record('test event').queries.pop().output.pop().match(expectedOutput).should.be.ok

describe 'Set', ->
	it 'should set properties', ->
		expectedOutput = /GET \/?s\?place=home&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.set({place: 'home'}).queries.pop().output.pop().match(expectedOutput).should.be.ok

	it 'should set multiple properties', ->
		expectedOutput = /GET \/?s\?place=home&otherPlace=work&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.set({place: 'home', otherPlace: 'work'}).queries.pop().output.pop().match(expectedOutput).should.be.ok

describe 'Alias', ->
	it 'should alias people', ->
		expectedOutput  = /GET \/?a\?_n=notevan%40example.com&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.alias('notevan@example.com').queries.pop().output.pop().match(expectedOutput).should.be.ok

	it 'should change person on alias', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.alias 'someone@example.com'
		km.person.should.be.equal 'someone@example.com'

describe 'Client API', ->
	it 'should be chainable', ->
		expectedOutput  = /GET \/?a\?_n=notevan%40example.com&_k=apiKey&_p=evan%40example\.com HTTP\/1\.1/

		km = new KM 'apiKey', 'evan@example.com'
		km.record('foo').alias('notevan@example.com').queries.pop().output.pop().match(expectedOutput).should.be.ok

	it 'should require apiKey', ->
		km = new KM 'apiKey', 'evan@example.com'
		delete km.apiKey

		(-> km.record 'foo').should.throw "API key required"

	it 'should require person', ->
		km = new KM 'apiKey', 'evan@example.com'
		delete km.person

		(-> km.record 'foo').should.throw 'Person required'

describe 'Query log', ->
	it 'should log all queries', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.record('foo').record('bar').set({foo: 'bar'}).alias('someone else')

		km.queries.length.should.be.equal 4

	it 'should log queries in order', ->
		km = new KM 'apiKey', 'evan@example.com'
		km.record('foo')
		firstQueryLogged = km.queries[0]

		km.record('bar').set({foo: 'bar'}).alias('someone else')
		km.queries[0].should.be.equal firstQueryLogged
