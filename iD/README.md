# iD Editor container

To set up this container you have to follow the next steps:


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
* Set the following env variables

```
SERVER_URL=127.0.0.1
SERVER_PROTOCOL=http
URLROOT='http:\/\/'$SERVER_URL
OAUTH_CONSUMER_KEY='<cosumer key from the register aplication>'
OAUTH_SECRET='<oauth secret key from the register aplication>'
```

```
docker build -t id .
```



```
docker run \
--network osm_seed_default \
-p "8081:8080" \
-it id 
```