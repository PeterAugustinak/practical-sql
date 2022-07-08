-- IMPORT DATA

-- create table to prepare for import data
CREATE TABLE us_counties_pop_est_2019 (
    state_fips text,                         -- State FIPS code
    county_fips text,                        -- County FIPS code
    region smallint,                         -- Region
    state_name text,                         -- State name
    county_name text,                        -- County name
    area_land bigint,                        -- Area (Land) in square meters
    area_water bigint,                       -- Area (Water) in square meters
    internal_point_lat numeric(10,7),        -- Internal point (latitude)
    internal_point_lon numeric(10,7),        -- Internal point (longitude)
    pop_est_2018 integer,                    -- 2018-07-01 resident total population estimate
    pop_est_2019 integer,                    -- 2019-07-01 resident total population estimate
    births_2019 integer,                     -- Births from 2018-07-01 to 2019-06-30
    deaths_2019 integer,                     -- Deaths from 2018-07-01 to 2019-06-30
    international_migr_2019 integer,         -- Net international migration from 2018-07-01 to 2019-06-30
    domestic_migr_2019 integer,              -- Net domestic migration from 2018-07-01 to 2019-06-30
    residual_2019 integer,                   -- Residual for 2018-07-01 to 2019-06-30
    CONSTRAINT counties_2019_key PRIMARY KEY (state_fips, county_fips)
);

SELECT * FROM us_counties_pop_est_2019;

-- import data from file to table
COPY us_counties_pop_est_2019
FROM '/var/lib/postgresql/us_counties_pop_est_2019.csv'
WITH (FORMAT CSV, HEADER);

-- inspecting import
SELECT county_name, state_name, area_land
FROM us_counties_pop_est_2019
ORDER BY area_land DESC
LIMIT 3;

SELECT county_name, state_name, internal_point_lat, internal_point_lon
FROM us_counties_pop_est_2019
ORDER BY internal_point_lon DESC
LIMIT 5;

-- import subset of columns
CREATE TABLE supervisor_salaries (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    town text,
    county text,
    supervisor text,
    start_date text,
    salary numeric(10,2),
    benefits numeric(10,2)
);

-- import with error as columns are not same as in file - our table starts with
-- id
COPY supervisor_salaries
FROM '/var/lib/postgresql/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

-- copy SUBSET OF COLUMNS - not specified will be added as <null? in the table
COPY supervisor_salaries (town, supervisor, salary)
FROM '/var/lib/postgresql/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

-- cleaning table
DELETE FROM supervisor_salaries;

-- importing SUBSET OF ROWS
COPY supervisor_salaries (town, supervisor, salary)
FROM '/var/lib/postgresql/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER)
WHERE town = 'New Brillig';

-- adding a value to a column during the import
CREATE TEMPORARY TABLE supervisor_salaries_temp
(LIKE supervisor_salaries INCLUDING ALL); -- same settings for temp table

COPY supervisor_salaries_temp (town, supervisor, salary)
FROM '/var/lib/postgresql/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

INSERT INTO supervisor_salaries (town, county, supervisor, salary)
SELECT town, 'Mills', supervisor, salary -- col will be added with default val
FROM supervisor_salaries_temp;

DROP TABLE supervisor_salaries_temp;


-- EXPORT DATA

-- exporting all data
COPY us_counties_pop_est_2019
TO '/var/lib/postgresql/us_counties_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- exporting particular columns
COPY us_counties_pop_est_2019
    (county_name, internal_point_lat, internal_point_lon)
TO '/var/lib/postgresql/us_counties_export_specific_columns.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '-');

-- exporting query results
COPY (
    SELECT county_name, state_name
    FROM us_counties_pop_est_2019
    WHERE county_name ILIKE '%mill%'
    )
TO '/var/lib/postgresql/us_counties_export_specific_columns_from_select.txt'
WITH (FORMAT CSV, HEADER);


-- try it yourself exercises
CREATE TABLE movies_actor (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movie text,
    actor text
);

COPY movies_actor (id, movie, actor)
FROM '/var/lib/postgresql/movies_actor.txt'
WITH (FORMAT CSV , HEADER, DELIMITER ':'); -- not working :(
