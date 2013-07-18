Wowza = require '../src/wowza'

_cfg = require './credentials'
	
client = new Wowza(_cfg)

start = new Date();
opts =
	outputPath: '/mnt/s3/recordings',
	outputFile: "#{start.getUTCFullYear()}-#{start.getUTCMonth()+1}-#{start.getUTCDate()}T#{start.getUTCHours()}.#{start.getUTCMinutes()}.#{start.getUTCSeconds()}.mp4"
	
client.startRecording 'live-1', opts