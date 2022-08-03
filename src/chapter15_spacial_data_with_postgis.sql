-- installing postgis into postgres running in docker
-- docker exec -it [postgres container name] bash
-- apt-get install postgis postgresql-14-postgis-3
-- check if postgis files are in /usr/share/postgresql/14/extension/
-- make current user super user if he is not:
-- still in container bash:
-- su - postgres
-- psql
-- ALTER ROLE [user name] SUPERUSER;
-- now it should be ok to create extension
CREATE EXTENSION postgis;


