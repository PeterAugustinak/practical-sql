/*
 - installing postgis into postgres running in docker
 - docker exec -it [postgres container name] bash
 - apt-get install postgis postgresql-14-postgis-3
 - check if postgis files are in /usr/share/postgresql/14/extension/
 - make current user super user if he is not:
 - still in container bash:
 - su - postgres
 - psql
 - ALTER ROLE [user name] SUPERUSER;
 - now it should be ok to create extension
*/
 CREATE EXTENSION postgis;
SELECT postgis_full_version();

/*
 - spacial building blocks:
 - Point -> single location
 - LineString -> roads, streams
 - Polygon -> structure, building
 - MultiPoint -> multiple locations
 - MultiLineString -> road with non-continuous segments
 - MultiPolygon -> several buildings
*/

-- FORMATS:
-- WKT -> text-based format represents geometry (longitude, latitude)

SELECT srtext
FROM spatial_ref_sys
WHERE srid = 4326;

/*
PostGIS data types:
 - geography - data type based on sphere, round-earth, longitude and latitude
   for large areas
 - geometry - data type based on plane, Euclidean coordinate - for small areas

*/

-- creating a geometry type from well-known text (WKT)
SELECT ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326);

SELECT ST_GeomFromText('LINESTRING(-74.9 42.7, -75.1 42.7)', 4326);

SELECT ST_GeomFromText('POLYGON((-74.9 42.7, -75.1 42.7,
                                 -75.1 42.6, -74.9 42.7))', 4326);

SELECT ST_GeomFromText('MULTIPOINT (-74.9 42.7, -75.1 42.7)', 4326);

SELECT ST_GeomFromText('MULTILINESTRING((-76.27 43.1, -76.06 43.08),
                                        (-76.2 43.3, -76.2 43.4,
                                         -76.4 43.1))', 4326);

SELECT ST_GeomFromText('MULTIPOLYGON((
                                     (-74.92 42.7, -75.06 42.71,
                                      -75.07 42.64, -74.92 42.7),
                                     (-75.0 42.66, -75.0 42.64,
                                      -74.98 42.64, -74.98 42.66,
                                      -75.0 42.66)))', 4326);

-- creating a geography type from WKT
SELECT
ST_GeogFromText('SRID=4326;MULTIPOINT(-74.9 42.7, -75.1 42.7, -74.924 42.6)');

-- Point functions

SELECT ST_PointFromText('POINT(-74.9233606 42.699992)', 4326);

SELECT ST_MakePoint(-74.9233606, 42.699992);
SELECT ST_SetSRID(ST_MakePoint(-74.9233606, 42.699992), 4326);

-- LineString functions

SELECT ST_LineFromText('LINESTRING(-105.90 35.67,-105.91 35.67)', 4326);
SELECT ST_MakeLine(ST_MakePoint(-74.9, 42.7), ST_MakePoint(-74.1, 42.4));

-- Polygons functions
SELECT ST_PolygonFromText('POLYGON((-74.9 42.7, -75.1 42.7,
                                    -75.1 42.6, -74.9 42.7))', 4326);

SELECT ST_MakePolygon(
           ST_GeomFromText('LINESTRING(-74.92 42.7, -75.06 42.71,
                                       -75.07 42.64, -74.92 42.7)', 4326));

SELECT ST_MPolyFromText('MULTIPOLYGON((
                                       (-74.92 42.7, -75.06 42.71,
                                        -75.07 42.64, -74.92 42.7),
                                       (-75.0 42.66, -75.0 42.64,
                                        -74.98 42.64, -74.98 42.66,
                                        -75.0 42.66)
                                      ))', 4326);


-- Analyzing farmers market data
CREATE TABLE farmers_markets (
    fmid bigint PRIMARY KEY,
    market_name text NOT NULL,
    street text,
    city text,
    county text,
    st text NOT NULL,
    zip text,
    longitude numeric(10,7),
    latitude numeric(10,7),
    organic text NOT NULL
);

COPY farmers_markets
FROM '/var/lib/postgresql/farmers_markets.csv'
WITH (FORMAT CSV, HEADER);

SELECT count(*) FROM farmers_markets;

-- creating and filling geography column
ALTER TABLE farmers_markets
    ADD COLUMN geog_point geography(POINT,4326);

UPDATE farmers_markets
SET geog_point =
     ST_SetSRID(
               ST_MakePoint(longitude,latitude)::geography,4326
               );

CREATE INDEX market_pts_idx ON farmers_markets USING GIST(geog_point);

SELECT longitude,
       latitude,
       geog_point,
       ST_AsEWKT(geog_point)
FROM farmers_markets
WHERE longitude IS NOT NULL
LIMIT 5;

-- finding geographies within a given distance
-- ST_DWithin - returns true if the object (geog_point - geog1) is in the
-- distance of (tolerance) with our point (geog2)
-- we can use ST_DFullyWithin if we are working with objects
SELECT market_name,
       city,
       st,
       geog_point
FROM farmers_markets
WHERE ST_DWithin(geog_point,
                 ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
                 10000)
ORDER BY market_name;

-- finding a distance between geographies
SELECT ST_Distance(
                   ST_GeogFromText('POINT(-73.9283685 40.8296466)'),
                   ST_GeogFromText('POINT(-73.8480153 40.7570917)')
                   )  AS mets_to_yanks;

-- distance of farmers market
SELECT market_name,
       city,
       geog_point,
       round(
           (ST_Distance(geog_point,
                        ST_GeogFromText('POINT(-93.6204386 41.5853202)')
                        ))::numeric, 2
            ) AS meters_from_dt
FROM farmers_markets
WHERE ST_DWithin(geog_point,
                 ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
                 10000)
ORDER BY meters_from_dt ASC;

-- finding the nearest geographies
-- instead of using WHERE with ST_DWithin to define distance, just make chart
-- with distances ordered
SELECT market_name,
       city,
       st,
       geog_point,
       round(
           (ST_Distance(geog_point,
                        ST_GeogFromText('POINT(-68.2041607 44.3876414)')
                        )/1000)::numeric, 2
            ) AS km_from_bh
FROM farmers_markets
ORDER BY geog_point <-> ST_GeogFromText('POINT(-68.2041607 44.3876414)')
LIMIT 50;


-- Working with Census shapefiles
-- import shp file to postgres
-- shp2pgsql -I -s 4269 -W LATIN1 tl_2019_us_county.shp us_counties_2019_shp | psql -d analysis -U postgres

-- checking the geom columns
SELECT ST_AsText(geom)
FROM us_counties_2019_shp
ORDER BY gid
LIMIT 1;

-- finding the largest counties by area
SELECT name,
       statefp AS st,
       round(
             ( ST_Area(geom::geography) / 1000000)::numeric, 2
            )  AS square_kms
FROM us_counties_2019_shp
ORDER BY square_kms DESC
LIMIT 5;

-- finding a county by longitude and latitude
SELECT sh.name,
       c.state_name
FROM us_counties_2019_shp sh JOIN us_counties_pop_est_2019 c
    ON sh.statefp = c.state_fips AND sh.countyfp = c.county_fips
WHERE ST_Within(
         'SRID=4269;POINT(-118.3419063 34.0977076)'::geometry, geom
);

-- using ST_DWithin to count people near the city
SELECT sum(c.pop_est_2019) AS pop_est_2019
FROM us_counties_2019_shp sh JOIN us_counties_pop_est_2019 c
    ON sh.statefp = c.state_fips AND sh.countyfp = c.county_fips
WHERE ST_DWithin(sh.geom::geography,
          ST_GeogFromText('SRID=4269;POINT(-96.699656 40.811567)'),
          80467);
