### Docker setup for openstreetmap-website

The docker container installs dependencies required for the website, checks out the latest openstreetmap-website code from github and sets up config files.

Config files can be edited in the `config/` folder.


### Running container by itself

- Build

```
docker build -t prod .

```

- Run

```
docker run -p "80:80" -h localhost -it prod /bin/bash
```