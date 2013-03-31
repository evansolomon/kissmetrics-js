should = require 'should'
KM     = require '../src/kissmetrics'

describe 'KM module', ->
	it 'should exist', ->
		should.exist KM

describe 'KM instance', ->
	it 'should initialize', ->
		km = new KM.KissmetricsClient 'apiKey', 'evan@example.com'
		km.key.should.equal 'apiKey'
		km.person.should.equal 'evan@example.com'

	it 'should have API methods', ->
		km = new KM.KissmetricsClient 'apiKey', 'evan@example.com'
		km.should.have.property 'record'
		km.should.have.property 'set'
		km.should.have.property 'alias'

	it 'should record events', ->
		expectedOutput  = 'GET /e?_n=test%20event&_k=apiKey&_p=evan%40example.com HTTP/1.1\r\n'
		expectedOutput += 'Host: trk.kissmetrics.com:80\r\n'
		expectedOutput += 'Connection: keep-alive\r\n\r\n'

		km = new KM.KissmetricsClient 'apiKey', 'evan@example.com'
		km.record('test event').output.pop().should.equal expectedOutput

	it 'should set properties', ->
		expectedOutput  = 'GET /s?place=home&_k=apiKey&_p=evan%40example.com HTTP/1.1\r\n'
		expectedOutput += 'Host: trk.kissmetrics.com:80\r\n'
		expectedOutput += 'Connection: keep-alive\r\n\r\n'

		km = new KM.KissmetricsClient 'apiKey', 'evan@example.com'
		km.set({place: 'home'}).pop().output.pop().should.equal expectedOutput

	it 'should alias people', ->
		expectedOutput  = 'GET /a?_n=notevan%40example.com&_k=apiKey&_p=evan%40example.com HTTP/1.1\r\n'
		expectedOutput += 'Host: trk.kissmetrics.com:80\r\n'
		expectedOutput += 'Connection: keep-alive\r\n\r\n'

		km = new KM.KissmetricsClient 'apiKey', 'evan@example.com'
		km.alias('notevan@example.com').output.pop().should.equal expectedOutput
