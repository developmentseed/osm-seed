# Nominatim  (Nominatim version 4.0)

This version of Nominatim was copy from https://github.com/mediagis/nominatim-docker/tree/master/4.1, with certain updates  to fit in osm-seed enviroment

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.nominatim.example](./../../envs/.env.nominatim.example)

**Note**: Rename the above files as `.env.nominatim`

### Log outputs in the container

```
/var/log/replication.log
/var/log/cron.log
```