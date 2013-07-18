Wowza = require '../src/wowza'
_cfg = require './credentials'
	
client = new Wowza(_cfg)

client.startStats()

client.on 'stats', (d)->
	client.stopStats();
	console.log(d)