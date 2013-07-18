{parseString} = require 'xml2js'
digest = require('./lib/digest');
_ = require('underscore')
querystring = require('querystring')

rest = require('http')
util = require('util')
crypto = require('crypto')
qs = require('querystring')
events = require 'events'
url = require 'url'


Wowza = (config)->
	@config = config
	@digest = new digest(@config.username, @config.password, @config.host);
	@timers =
		stats: false
	url = url.parse(@config.host);
	@config.host = url.hostname;
	@config.port = url.port
	@config.path = url.path
	Wowza.self = this
	events.EventEmitter.call this;
	return this
	
	
util.inherits(Wowza, events.EventEmitter)
Wowza.self = false;

Wowza.recordingOptions =
	outputPath: '/usr/local/WowzaMediaServer/content/recordings/'
	outputFile: 'liveRecording.mp4'
	format: 2 #mpeg4
	app: 'live'
	option: 'overwrite'
	SegmentSize: 500*1024*1024 #500Mb
	SegmentDuration: 60*60 #1 hour
	


Wowza.prototype.startStats = ()->
	return false if @timers.stats;
	statFn = ()=>
		@request '/connectioncounts', (data)=>
			@timers.stats = setTimeout(statFn, 5000);
			parseString data, (err, d)=>
				if err
					Wowza.self.emit('error.stats', "Couldn't get stats")
					return false
				try
					data = {time:new Date(), count: parseInt(d.WowzaMediaServer.VHost[0].Application[0].ConnectionsCurrent[0], 10)}
					Wowza.self.emit('stats', data);
				catch err
					console.log('error')
					console.error(err)
					Wowza.self.emit('error.stats', err);
				
	statFn()

Wowza.prototype.stopStats = ()->
	clearTimeout @timers.stats
	return true

Wowza.prototype.startRecording = (streamName, options={})->
	options = _.defaults(options, Wowza.recordingOptions)
	
	options.action = 'startRecording'
	options.streamName = streamName
	qs = querystring.stringify(options)#.replace(/%2F/g, '/')
	console.log qs
	@request "/livestreamrecord?#{qs}", (data)=>
		console.log data
Wowza.prototype.stopRecording = ()->
	options = _.defaults(options, Wowza.recordingOptions)
	
	options.action = 'stopRecording'
	options.streamName = streamName
	qs = querystring.stringify options
	
	@request "/livestreamrecord?#{qs}", (data)=>
		console.log data

Wowza.prototype.parse = (response, callback)->
	d ='';
	response.on 'data', (chunk)->
		d+=chunk;
		return true;
	
	response.on 'end', ()->
		callback(d)
		return true;
	
	return true

Wowza.prototype.request = (url, callback)->
	self = this;
	opts =
		host: @config.host,
		port: @config.port,
		path: url,
		method: 'get'
	r1 = rest.request(opts)
	r1.end();
	r1.on 'error', (err)->
		util.error("Can't get stats");
	r1.on 'response', (response)=>
		
		headers = @digest.render(opts.path, response.headers)
		opts2 =
			host: @config.host,
			port: @config.port,
			path: opts.path,
			method: 'get',
			headers: headers
				
		req = rest.request(opts2)
		req.end();
		req.on 'error', (err)->
			util.error("Wowza error:");
			util.error(err);
		req.on 'response', (response)->
			Wowza.self.parse response, callback


Wowza.prototype.stop =()->
	clearInterval(@timer)

module.exports = Wowza