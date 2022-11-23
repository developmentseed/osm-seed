# Web dashbord 
This container is for user management in the Web APi database.

- Development mode

```
docker-compose -f compose/web.yml up db
docker-compose -f compose/web.yml up web
docker-compose -f compose/web.yml run --service-ports web_dashboard bash
``