-- PRIMARY KEYS
-- single-column primary key
-- PRIMARY KEY defined within row
CREATE TABLE natural_key_example (
    license_id text CONSTRAINT license_key PRIMARY KEY,
    first_name text,
    last_name text
);

SELECT * FROM natural_key_example;

DROP TABLE natural_key_example;

-- PRIMARY KEY defined within table
CREATE TABLE natural_key_example (
    license_id text,
    first_name text,
    last_name text,
    CONSTRAINT license_key PRIMARY KEY (license_id)
);

INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Gem', 'Godfrey');

-- same PRIMARY KEY will throw an error as PRIMARY KEY is UNIQUE by default
INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'John', 'Mitchell');

-- creating a composite PRIMARY KEY (multi-column)
CREATE TABLE natural_key_composite_example (
    student_id text,
    school_day date,
    present boolean,
    CONSTRAINT student_key PRIMARY KEY (student_id, school_day)
);

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '2022-01-22', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '2022-01-23', 'Y');

-- using the same combination of student_id and school_dat will throw an error
INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '2022-01-23', 'N');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(776, '2022-01-23', 'N');

SELECT * FROM natural_key_composite_example;

-- creating and auto-incrementing surrogate key
CREATE TABLE surrogate_key_example (
    order_number bigint GENERATED ALWAYS AS IDENTITY,
    product_name text,
    order_time timestamp with time zone,
    CONSTRAINT order_number_key PRIMARY KEY (order_number)
);

INSERT INTO surrogate_key_example (product_name, order_time)
VALUES ('Beachball Polish', '2020-03-15 09:21-07'),
       ('Wrinkle De-Atomizer', '2017-05-22 14:00-07'),
       ('Flux Capacitor', '1985-10-26 01:18:00-07');

-- overriding and restarting the surrogate (identity) key
INSERT INTO surrogate_key_example
OVERRIDING SYSTEM VALUE
VALUES  (4, 'Chicken Coop', '2021-09-03 10:33-08');

-- this will throw error as the 4 is already occupied by manual insert
INSERT INTO surrogate_key_example (product_name, order_time)
VALUES  ('Chicken Coop', '2021-09-03 10:33-08');

-- numbering must be reset at first
ALTER TABLE surrogate_key_example
ALTER COLUMN order_number RESTART with 5;

-- now new entry can be added
INSERT INTO surrogate_key_example (product_name, order_time)
VALUES  ('Chicken Coop', '2021-09-03 10:33-08');

-- FOREIGN KEYS
CREATE TABLE licences (
    license_id text,
    first_name text,
    last_name text,
    CONSTRAINT licenses_key PRIMARY KEY (license_id)
);

CREATE TABLE registrations (
    registration_id text,
    registration_date timestamp with time zone,
    license_id text REFERENCES licences (license_id),
    CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

INSERT INTO licences (license_id, first_name, last_name)
VALUES ('T229901', 'Steve', 'Rothery');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A203391', '2022-03-17', 'T229901');

-- this throws error as the license_id (foreign key) does not exists in reference table
INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A75772', '2022-03-17', 'T000001');

DROP TABLE registrations;

-- automatically delete related records with CASCADE
CREATE TABLE registrations (
    registration_id text,
    registration_date date,
    license_id text REFERENCES licences (license_id) ON DELETE CASCADE,
    CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

DELETE FROM licences WHERE license_id = 'T229901';


-- the CHECK constraint
CREATE TABLE check_constraint_example (
    user_id bigint GENERATED ALWAYS AS IDENTITY,
    user_role text,
    salary numeric (10, 2),
    CONSTRAINT user_id_key PRIMARY KEY (user_id),
    CONSTRAINT check_role_in_list CHECK (user_role IN ('Admin', 'Staff')),
    CONSTRAINT check_salary_not_below_zero CHECK (salary >= 0)
-- or it can be defined as:
-- CONSTRAINT check_values CHECK (user_role IN () AND salary >- 0)
);

-- this throws error as the checks are violated
INSERT INTO check_constraint_example (user_role, salary)
VALUES ('SomeRole', -22);


-- the  UNIQUE constraint
CREATE TABLE unique_constraint_example (
    contact_id bigint GENERATED ALWAYS AS IDENTITY,
    first_name text,
    last_name text,
    email text,
    CONSTRAINT contact_id_key PRIMARY KEY (contact_id),
    CONSTRAINT  email_unique UNIQUE (email)
);

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Samantha', 'Lee', 'slee@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Betty', 'Diaz', 'bdiaz@example.org');

-- this throws error as the email already exists in the table
INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Sasha', 'Lee', 'slee@example.org');


-- the NOT NULL constraint
CREATE TABLE not_null_example (
    student_id bigint GENERATED ALWAYS AS IDENTITY,
    first_name text NOT NULL,
    last_name text NOT NULL ,
    CONSTRAINT student_id_key PRIMARY KEY (student_id)
);

-- this throws error as the null is not accepted
INSERT INTO not_null_example (first_name)
VALUES ('Sting');


-- removing and adding constraints
/*
 ALTER TABLE table_name
 DROP CONSTRAINT constraint_name;

 - specific for NOT NULL as this is tied to column
 ALTER TABLE table_name
 ALTER COLUMN column_name DROP NOT NULL;
 */

ALTER TABLE not_null_example
DROP CONSTRAINT student_id_key;
ALTER TABLE not_null_example
ADD CONSTRAINT student_id_key PRIMARY KEY (student_id);

ALTER TABLE not_null_example
ALTER COLUMN first_name DROP NOT NULL;
ALTER TABLE not_null_example
ALTER COLUMN first_name SET NOT NULL;

-- DROP TABLE not_null_example;

-- speeding up queries with INDEXES
-- B-Tree - postrgesql default index
CREATE TABLE new_york_addresses (
    longitude numeric (9, 6),
    latitude numeric (9, 6),
    street_number text,
    street text,
    unit text,
    postcode text,
    id integer CONSTRAINT new_york_key PRIMARY KEY
);

COPY new_york_addresses
FROM '/var/lib/postgresql/city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);

-- benchmarking queries with EXPLAIN and ANALYZE
EXPLAIN ANALYZE SELECT *
FROM new_york_addresses
WHERE street = 'BROADWAY'; -- 38.116ms / 3.770ms

EXPLAIN ANALYZE SELECT *
FROM new_york_addresses
WHERE street = '52 STREET'; -- 37.648ms / 8.209ms

EXPLAIN ANALYZE SELECT *
FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE'; -- 40.795ms / 0.129ms

-- adding INDEX
CREATE INDEX street_indx ON new_york_addresses (street);


-- try it for yourself
CREATE TABLE albums (
    album_id bigint GENERATED ALWAYS AS IDENTITY,
    catalog_code text,
    title text NOT NULL ,
    release_date date,
    genre text NOT NULL CONSTRAINT check_genre CHECK (genre IN ('punk', 'metal')), -- added check to verify if genre is real
    description text
    -- could be defined as natural key CONSTRAINT album_key PRIMARY KEY (catalog_code, release_date)
);

CREATE TABLE songs (
    song_id bigint GENERATED ALWAYS AS IDENTITY,
    title text NOT NULL,
    composers text CON,
    album_id bigint REFERENCES albums (album_id) ON DELETE CASCADE -- added foreign key + cascade delete
);

CREATE INDEX title_index ON albums (title); -- index for most sought column
CREATE INDEX album_id_index ON songs (album_id); -- index for foreign key
