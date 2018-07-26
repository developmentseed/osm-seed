var http = require('http');
http.createServer(function (req, res) {
  res.write(
    `Create an account in osm-see and register an application and then set these parameters
    - SERVER_URL
    - OAUTH_CONSUMER_KEY
    - OAUTH_SECRET
    then update the stack!`);
  res.end();
}).listen(8080);