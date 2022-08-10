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
 json #>>text array - extracts json object at specified path as text
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


-- Analyzing earthquake data
