# A very incomplete WowzaMediaServer Client for Node.js

## Installation

    npm install wowza-control

## Usage

```javascript
var Wowza, client, _cfg;

Wowza = require('../src/wowza');

_cfg = {
	"username": 'someUser',
	"password": 'somePassword',
	"host": 'http://some.server:8086'
};

client = new Wowza(_cfg);

//find client connections of first app
client.startStats();

client.on('stats', function(d) {
	console.log(d)
});

//Start recording a stream
// Full option list on client.recordingOptions
start = new Date();

opts = {
  outputPath: '/mnt/s3/recordings',
  outputFile: "" + (start.getUTCFullYear()) + "-" + (start.getUTCMonth() + 1) + "-" + (start.getUTCDate()) + "T" + (start.getUTCHours()) + "." + (start.getUTCMinutes()) + "." + (start.getUTCSeconds()) + ".mp4"
};

client.startRecording('streamName', opts);

setTimeout(function(){
	client.stopRecording('live-1', opts);
}, 5*60);

```

## License
![What the fuck Public License](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-1.png)


As usual, licensed under the [WTFPL](http://www.wtfpl.net).
