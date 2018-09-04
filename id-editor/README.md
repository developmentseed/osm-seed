# iD Editor container

osm-seed iD-editor has a communication with the osm-seed api, We set up iD editor in the port `8080` since we are using a specific container run the application.


When you run ad first time the osm-seed iD-editor at port `8080`, you will get a notification to register an application. You should create the application and the update the in the following parameter in your `.env`  or `values.yaml` file.

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
* Set the following env variables in `.env`  or `values.yaml`

```
SERVER_URL=127.0.0.1
SERVER_PROTOCOL=http
OAUTH_CONSUMER_KEY='<cosumer key from the register aplication>'
OAUTH_SECRET='<oauth secret key from the register aplication>'
```

Finally, update the osm-seed stack:

- Docker

```
docker-compose down && docker-compose up
```

- kubernetes

```
cd osm-seed/helm/
helm upgrade -f osm-seed/values.yaml osm-seed osm-seed/
```

The next time when you start the iD editor, it will be available to use.


### Building the container


```
docker build -t osmseed-id-editor:v1 .
```

### Running the container

```
docker run \
--env-file ./../.env \
--network osm-seed_default \
-p "8080:8080" \
-it osmseed-id-editor:v1
```