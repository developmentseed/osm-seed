var http = require('http');
http.createServer(function (req, res) {
  res.write(
    `If you are looking at this page it is because you need to register your application and set the ENV variables in your .env or values.yaml:
Do the following:
* Log into your Rails Port instance - e.g. http://localhost
* Click on your user name to go to your user page
* Click on "my settings" on the user page
* Click on "oauth settings" on the My settings page
* Click on 'Register your application'.
* Unless you have set up alternatives, use Name: "iD-Editor " and URL: "http://localhost"
* Check the all the boxes
* Click the "Register" button
* On the next page, copy the "consumer key"
* Set the following env variables in  .env or values.yaml`);
  res.end();
}).listen(8080);