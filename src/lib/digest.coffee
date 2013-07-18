url = require 'url'
crypto = require 'crypto'

Digest = (@username, @password, urlString)->
	@config = {}
	url = url.parse(urlString);
	@config.host = url.hostname;
	@config.port = url.port
	
Digest.parseHeaders = (header)->
	obj = {}
	header.substring(7).split(/,\s+/).forEach (par)->
		d = par.split('=')
		obj[d[0]] = d[1].replace(/"/g, '');
	obj

Digest.prototype.renderHeaders = (obj)->
	d = []
	for k,v of obj
		d.push "#{k}=\"#{v}\""
		
	return "Digest #{d.join(', ')}"
	

Digest.prototype.render = (path, headers, method='GET')->
	arp = Digest.parseHeaders headers['www-authenticate']
	signatures =
		ha1: "#{@username}:#{arp.realm}:#{@password}"
		ha2: "#{method.toUpperCase()}:#{path}"
	
	h1 = crypto.createHash('md5').update(signatures.ha1).digest('hex')
	h2 = crypto.createHash('md5').update(signatures.ha2).digest('hex')	
	cnonce = ''
	resp = crypto.createHash('md5').update("#{h1}:#{arp.nonce}:1:#{cnonce}:auth:#{h2}").digest('hex')

	completeHeader =
		username: @username
		realm: arp.realm
		nonce: arp.nonce
		uri: path
		qop: arp.qop
		nc: '1'
		cnonce: cnonce,
		response: resp

	headers =
		Authorization: @renderHeaders(completeHeader)
		
module.exports = Digest