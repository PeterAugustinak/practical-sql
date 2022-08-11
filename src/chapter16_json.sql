-- json -> as text, ordered
-- jsonb - binary, removing white spaces, not ordered


CREATE TABLE  films
(
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    film jsonb NOT NULL
);

COPY films (film)
FROM '/var/lib/postgresql/films.json';

CREATE INDEX idx_film ON films USING GIN (film);

SELECT * FROM films;

/*
 Extraction syntax:
 json -> key, returns json
 jsonb -> key, returns jsonb
 json ->> key, returns text
 jsonb ->> key, returns text
 json -> int, returns array element in json
 jsonb -> int, returns array element in jsonb
 json ->> int, returns array element as text
 jsonb ->> int, returns array element as text
 json #> text array - extracts json object at specified path as json
 jsonb #> text array - extracts json object at specified path as jsonb
 json #>> text array - extracts json object at specified path as text
 jsonb #>> text array - extracts json object at specified path as text
*/

-- key value extraction
SELECT id, film -> 'title'  AS title
FROM films
ORDER BY id;

SELECT id, film ->> 'title' AS title
FROM films
ORDER BY id;

SELECT id, film -> 'genre' AS genre
FROM films
ORDER BY id;

-- array element extraction
SELECT id, film -> 'genre' -> 0 AS genres
FROM films
ORDER by id;

SELECT id, film -> 'genre' -> -1 AS genres
FROM films
ORDER BY id;

-- if index does not exists in array, null is returned
SELECT id, film -> 'genre' -> 2 AS genres
FROM films
ORDER BY id;

SELECT id, film -> 'genre' ->> 0 AS genres
FROM films
ORDER BY id;

-- path extraction
--  object in json:
--  "rating": {"MPAA": "PG"}
SELECT id ,film #> '{rating, MPAA}' AS mpaa_rating
FROM films
ORDER BY id;

-- object in list in json:
-- "characters": [{"name": "Mr. Incredible", "actor":  ...]}
SELECT id, film #> '{characters, 0, name}' AS name
FROM films
ORDER BY id;


SELECT id, film #>> '{characters, 0, name}' AS name
FROM films
ORDER BY id;


-- JSONB CONTAINMENT AND EXISTENCE OPERATORS
-- containment operators
/*
 works only with jsonn
 jsonb @> jsonb - test if json has json value and returns boolean
 jsonb <@ jsonb - test whether second json contains first json value, boolean
 */

-- using containment operators
SELECT id, film ->> 'title' AS title,
       film @> '{"title": "The Incredibles"}'::jsonb AS is_incredible
FROM films
ORDER BY id;

-- used in where clause
SELECT film ->> 'title' AS title,
       film ->> 'year' AS year
FROM films
WHERE film @> '{"title": "The Incredibles"}'::jsonb;

SELECT film ->> 'title' AS title,
       film ->> 'year' AS year
FROM films
WHERE '{"title": "The Incredibles"}'::jsonb <@ film;

-- existence operators
/*
 works only with jsonn
 jsonb ? text: tests whether test exists as top level key or array value, bool
 jsonb ?| (OR) text array: test whether text elem in array exists, bool
 jsonb ?& (AND) text array: if all array elem exist in top level, bool
 */

-- using existence operators
SELECT film ->> 'title' AS title
FROM films
WHERE film ? 'rating'

SELECT film ->> 'title' AS title,
       film ->> 'rating' AS rating,
       film ->> 'genre' AS genre
FROM films
WHERE film ?| '{rating, genre}';

SELECT film ->> 'title' AS title,
       film ->> 'rating' AS rating,
       film ->> 'genre' AS genre
FROM films
WHERE film ?& '{rating, genre}';


-- ANALYZING EARTHQUAKE DATA
CREATE TABLE earthquakes (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    earthquake jsonb NOT NULL
);

COPY earthquakes (earthquake)
FROM '/var/lib/postgresql/earthquakes.json';

CREATE INDEX idx_earthquakes ON earthquakes USING GIN (earthquake);

SELECT * FROM earthquakes ORDER BY id;

-- earthquake times
SELECT id, earthquake #>> '{properties, time}' AS time
FROM earthquakes
ORDER BY id LIMIT 5;

SELECT id, earthquake #>> '{properties, time}' AS time,
       to_timestamp(
           (
               earthquake #>> '{properties, time}'
               )::bigint / 1000
           ) AS time_formatted
FROM earthquakes
ORDER BY time_formatted DESC LIMIT 5;

-- find oldest and newest er. using aggregate funcs
-- See and set time zone if desired
SHOW timezone;
SET timezone TO 'UTC';

SELECT min(to_timestamp(
           (earthquake #>> '{properties, time}')::bigint / 1000
                       )) AT TIME ZONE 'UTC' AS min_timestamp,
       max(to_timestamp(
           (earthquake #>> '{properties, time}')::bigint / 1000
                       )) AT TIME ZONE 'UTC' AS max_timestamp
FROM earthquakes;

-- finding the largest and most reported earth.
-- extracting by magnitude
SELECT earthquake #>> '{properties, place}' AS place,
       to_timestamp((earthquake #>> '{properties, time}')::bigint / 1000)
           AT TIME ZONE 'UTC' AS time,
       (earthquake #>> '{properties, mag}')::numeric AS magnitude
FROM earthquakes
ORDER BY (earthquake #>> '{properties, mag}')::numeric DESC NULLS LAST
LIMIT 5;

-- instead of using a path extraction operator (#>>), you can also use field
-- extraction:
SELECT earthquake -> 'properties' ->> 'place' AS place,
       to_timestamp((earthquake -> 'properties' ->> 'time')::bigint / 1000)
           AT TIME ZONE 'UTC' AS time,
       (earthquake #>> '{properties, mag}')::numeric AS magnitude
FROM earthquakes
ORDER BY (earthquake #>> '{properties, mag}')::numeric DESC NULLS LAST
LIMIT 5;

-- extracting by citizen report
SELECT earthquake #>> '{properties, place}' AS place,
       to_timestamp((earthquake #>> '{properties, time}')::bigint / 1000)
           AT TIME ZONE 'UTC' AS time,
       (earthquake #>> '{properties, mag}')::numeric AS magnitude,
       (earthquake #>> '{properties, felt}')::integer AS felt
FROM earthquakes
ORDER BY (earthquake #>> '{properties, felt}')::integer DESC NULLS LAST
LIMIT 5;


-- Converting earthquake JSON to Spatial data
SELECT id,
       earthquake #>> '{geometry, coordinates}' AS coordinates,
       earthquake #>> '{geometry, coordinates, 0}' AS longitude,
       earthquake #>> '{geometry, coordinates, 1}' AS latitude
FROM earthquakes
ORDER BY id
LIMIT 5;

-- Converting JSON location data to PostGIS geography
SELECT ST_SetSRID(
         ST_MakePoint(
            (earthquake #>> '{geometry, coordinates, 0}')::numeric,
            (earthquake #>> '{geometry, coordinates, 1}')::numeric
         ),
             4326)::geography AS earthquake_point
FROM earthquakes
ORDER BY id;

-- finding earthquake within a distance
-- add column to earth. table
ALTER TABLE earthquakes ADD COLUMN earthquake_point geography(POINT, 4326);

-- update new column with Point data
UPDATE earthquakes
SET earthquake_point =
        ST_SetSRID(
            ST_MakePoint(
                (earthquake #>> '{geometry, coordinates, 0}')::numeric,
                (earthquake #>> '{geometry, coordinates, 1}')::numeric
             ),
                 4326)::geography;

-- adding index to the point
CREATE INDEX quake_pt_idx ON earthquakes USING GIST (earthquake_point);

-- finding earthquakes within 50 miles of downtown Tulsa, Oklahoma
SELECT earthquake #>> '{properties, place}' AS place,
       to_timestamp((earthquake -> 'properties' ->> 'time')::bigint / 1000)
           AT TIME ZONE 'UTC' AS time,
       (earthquake #>> '{properties, mag}')::numeric AS magnitude,
       earthquake_point,
       round(
           (ST_Distance(earthquake_point,
                        ST_GeogFromText('POINT(-95.989505 36.155007)')
                        )/1000)::numeric, 2
            ) AS km_from_city
FROM earthquakes
WHERE ST_DWithin(earthquake_point,
                 ST_GeogFromText('POINT(-95.989505 36.155007)'),
                 80468)
ORDER BY km_from_city;


-- GENERATING AND MANIPULATING JSON
-- Turning query results into JSON with to_json()

-- convert entire row from the table
SELECT to_json(employees) AS json_rows
FROM employees;

-- specify columns to return into JSON - column names are converted to generic
SELECT to_json(row(emp_id, last_name)) AS json_rows
FROM employees;

-- generating key names with subquery
SELECT to_json(employees) AS json_rows
FROM (
    SELECT emp_id, last_name AS ln FROM employees
) AS employees;

-- aggregating rows and converting to json - storing in one row in list
SELECT json_agg(to_json(employees)) AS json
FROM (
    SELECT emp_id, last_name AS ln FROM employees
) AS employees;

-- Adding or Updating top level key/value pair
UPDATE films
SET film = film || '{"studio": "Pixar"}'::jsonb
WHERE film @> '{"title": "The Incredibles"}'::jsonb;

-- OR

UPDATE films
SET film = film || jsonb_build_object('studio', 'Pixar')
WHERE film @> '{"title": "The Incredibles"}'::jsonb;

-- check the updated data
SELECT film -> 'studio' AS studio
FROM films
WHERE film @> '{"title": "The Incredibles"}'::jsonb;

-- updating a value at a path (add value into the list of key
UPDATE films
SET film = jsonb_set(film,
                 '{genre}',
                  film #> '{genre}' || '["World War II"]',
                  true)
WHERE film @> '{"title": "Cinema Paradiso"}'::jsonb;

 -- check the updated data
SELECT film -> 'genre' AS genre
FROM films
WHERE film @> '{"title": "Cinema Paradiso"}'::jsonb;

-- deleting value
-- removes the studio key/value pair from The Incredibles
UPDATE films
SET film = film - 'studio'
WHERE film @> '{"title": "The Incredibles"}'::jsonb;

-- removes the third element in the genre array of Cinema Paradiso
UPDATE films
SET film = film #- '{genre, 2}'
WHERE film @> '{"title": "Cinema Paradiso"}'::jsonb;


-- JSON PROCESSING FUNCTIONS
-- finding a length of an array
SELECT id,
       film ->> 'title' AS title,
       jsonb_array_length(film -> 'characters') AS num_characters
FROM films
ORDER BY id;

-- returning array elements as rows
SELECT id,
       jsonb_array_elements(film -> 'genre') AS genre_jsonb,
       jsonb_array_elements_text(film -> 'genre') AS genre_text
FROM films
ORDER BY id;

-- returning key values from each item in array
SELECT id,
       jsonb_array_elements(film -> 'characters')
FROM films
ORDER BY id;

-- transform those elements into separate columns
WITH characters (id, json) AS (
    SELECT id,
           jsonb_array_elements(film -> 'characters')
    FROM films
)
SELECT id,
       json ->> 'name' AS name,
       json ->> 'actor' AS actor
FROM characters
ORDER BY id;
