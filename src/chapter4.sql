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