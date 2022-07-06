-- basic data types definition
CREATE TABLE eagle_watch (
    observation_date date, -- temporal information
    eagles_seen integer, -- whole numbers and fractions
    notes text -- any character or symbol
);

-- characters data
CREATE TABLE char_data_types (
    char_column char(10),
    varchar_column varchar(10),
    text_column text
);

INSERT INTO char_data_types
VALUES
    ('abc', 'abc', 'abc'),
    ('defghi', 'defghi', 'defghi');

COPY char_data_types TO
'/chapter3_type_test.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- serial - postgres-specific implementation of auto-increment integer
CREATE TABLE people (
    id serial,
    person_name varchar(100)
);

-- smallserial -> 32 767
-- serial -> 2 147 483 647
-- bigserial -> more

INSERT INTO people (person_name) VALUES ('Jan');

-- IDENTITY - standard SQL implementation of auto-increment integer
CREATE TABLE people_identity (
    id integer GENERATED ALWAYS AS IDENTITY,
    person_name varchar(100)
);

INSERT INTO people_identity (person_name) VALUES ('Peter');

-- decimal numbers
CREATE TABLE number_data_types (
    numeric_column numeric(20, 5),
    real_column real,
    double_column double precision
);

INSERT INTO number_data_types
VALUES
    (.7, .7, .7),
    (2.13579, 2.13579, 2.13579),
    (2.1357987654, 2.1357987654, 2.1357987654);

-- floating-point math
SELECT numeric_column * 10000000 AS fixed,
       real_column * 10000000 AS floating
FROM number_data_types
WHERE numeric_column = .7;

-- dates
CREATE TABLE date_time_types (
    timestamp_column timestamp with time zone,
    interval_column interval);

INSERT INTO date_time_types
VALUES
    ('2022-12-31 01:00 EST', '2 days'),
    ('2022-12-31 01:00 -8', '1 month'),
    ('2022-12-31 01:00 Australia/Melbourne', '1 century'),
    (now(), '1 week');

SELECT * FROM date_time_types;

-- interval data type calculations
SELECT timestamp_column,
       interval_column,
       timestamp_column - date_time_types.interval_column AS new_date
FROM date_time_types;

-- casting types (changing one type to other)
SELECT timestamp_column,
       CAST(timestamp_column AS varchar(16)) AS dates_to_string
FROM date_time_types;

SELECT numeric_column,
       CAST(numeric_column AS integer) AS decimals_to_integer,
       CAST(numeric_column AS text) AS decimals_to_text
FROM number_data_types;

SELECT CAST(char_column AS integer)
FROM char_data_types; -- error as chars cannot be casted to integers

-- cast short shortcut notation
SELECT timestamp_column,
       CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT timestamp_column,
       timestamp_column::varchar(10) -- shorten version of cast, Postgres only!
FROM date_time_types;


-- try it yourself exercises
CREATE TABLE travel_data (
    first_name text,
    last_name text,
    driven_mileage smallint,
    date text
);

INSERT INTO travel_data
VALUES
    ('Peter', 'Aug', 234, '2022-05-22'),
    ('Milan', 'Bur', 999, '2021-06-23'),
    ('Thomas', 'Far', 12, '4//2021');

SELECT *,
       CAST(date AS timestamp)
FROM travel_data
WHERE first_name = 'Peter';

SELECT *,
       CAST(date AS timestamp)
FROM travel_data
WHERE first_name = 'Thomas'; -- incorrectly str formatted date calls error
