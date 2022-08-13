-- VIEWS

-- creating and querying views
CREATE OR REPLACE VIEW nevada_counties_pop_2019 AS
    SELECT county_name,
           state_fips,
           county_fips,
           pop_est_2019
FROM us_counties_pop_est_2019
WHERE state_name = 'Nevada';

SELECT *
FROM nevada_counties_pop_2019
ORDER BY county_fips
LIMIT 5;


CREATE OR REPLACE VIEW county_pop_change_2019_2010 AS
    SELECT c2019.county_name,
           c2019.state_name,
           c2019.state_fips,
           c2019.county_fips,
           c2019.pop_est_2019 AS pop_2019,
           c2010.estimates_base_2010 AS pop_2010,
           round((c2019.pop_est_2019::numeric - c2010.estimates_base_2010) /
           c2010.estimates_base_2010 * 100, 1) AS pct_change_2019_2010
    FROM us_counties_pop_est_2019 AS c2019
    JOIN
    us_counties_pop_est_2010 AS c2010
    ON c2019.state_fips = c2010.state_fips AND
    c2019.county_fips = c2010.county_fips;

SELECT county_name,
       state_name,
       pop_2019,
       pct_change_2019_2010
FROM county_pop_change_2019_2010
WHERE state_name = 'Nevada'
ORDER BY pct_change_2019_2010 DESC
LIMIT 5;


-- Creating and refreshing materialized view
DROP VIEW nevada_counties_pop_2019;

CREATE MATERIALIZED VIEW nevada_counties_pop_2019 AS
    SELECT county_name,
           state_fips,
           county_fips,
           pop_est_2019
FROM us_counties_pop_est_2019
WHERE state_name = 'Nevada';

REFRESH MATERIALIZED VIEW nevada_counties_pop_2019;


-- Inserting, Updating and Deleting Data Using View
-- (can't contain DISTINCT, WITH, GROUP BY)
SELECT * FROM employees ORDER BY emp_id;

CREATE OR REPLACE VIEW employees_tax_dept WITH (security_barrier) AS
    SELECT emp_id,
           first_name,
           last_name,
           dept_id
FROM employees
WHERE dept_id = 1
WITH LOCAL CHECK OPTION;

-- inserting rows using view
INSERT INTO employees_tax_dept (emp_id, first_name, last_name, dept_id)
VALUES (5, 'Suzanne', 'Legere', 1);

INSERT INTO employees_tax_dept (emp_id, first_name, last_name, dept_id)
VALUES (6, 'Jamil', 'White', 2) -- this is denied as the dept_id is not in view

SELECT * FROM employees_tax_dept ORDER BY emp_id;

-- refreshed also in original table
SELECT * FROM employees ORDER BY emp_id;

-- updating rows using view
UPDATE employees_tax_dept
SET last_name = 'Le Gere'
WHERE emp_id = 5;

-- deleting rows using view
DELETE FROM employees_tax_dept
WHERE emp_id = 5;


-- FUNCTIONS AND PROCEDURES

-- percent_change() function
-- percent change = (new number - old number) / old number

CREATE OR REPLACE FUNCTION percent_change(
    new_value numeric,
    old_value numeric,
    decimal_places integer DEFAULT 1
)
RETURNS numeric AS
    'SELECT round(((new_value - old_value) / old_value) * 100, decimal_places);'
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;

SELECT percent_change(110, 108, 2);
SELECT percent_change(110, 108); -- uses default value 1

-- comparison of created function vs direct formula
SELECT c2019.county_name,
       c2019.state_name,
       c2019.pop_est_2019 AS pop_2019,
       percent_change(c2019.pop_est_2019,
                      c2010.estimates_base_2010) AS pct_chg_func,
       round( (c2019.pop_est_2019::numeric - c2010.estimates_base_2010)
           / c2010.estimates_base_2010 * 100, 1 ) AS pct_chg_formula
FROM us_counties_pop_est_2019 AS c2019
    JOIN us_counties_pop_est_2010 AS c2010
ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
ORDER BY pct_chg_func DESC
LIMIT 5;


-- updating data with a procedure
ALTER TABLE teachers ADD COLUMN personal_days integer;

SELECT first_name,
       last_name,
       hire_date,
       personal_days
FROM teachers;

CREATE OR REPLACE PROCEDURE update_personal_days() AS
$$
BEGIN
    UPDATE teachers
    SET personal_days =
        CASE WHEN (now() - hire_date) >= '10 years'::interval
                  AND (now() - hire_date) < '15 years'::interval THEN 4
             WHEN (now() - hire_date) >= '15 years'::interval
                  AND (now() - hire_date) < '20 years'::interval THEN 5
             WHEN (now() - hire_date) >= '20 years'::interval
                  AND (now() - hire_date) < '25 years'::interval THEN 6
             WHEN (now() - hire_date) >= '25 years'::interval THEN 7
             ELSE 3
        END;
    RAISE NOTICE 'personal_days updated!';
END;
$$
LANGUAGE plpgsql;

INSERT INTO teachers (first_name, last_name, school, hire_date, salary)
    VALUES ('Peter', 'Augustinak', 'SPS Strojnicka', '2007-08-13', 100000);

CALL update_personal_days();


-- using Python in a function
CREATE EXTENSION plpython3u; -- install python extension (inside container)

CREATE OR REPLACE FUNCTION trim_county(input_string text)
RETURNS text AS
    $$
    import re
    cleaned = re.sub(r' County', '', input_string)
    return cleaned
    $$
LANGUAGE plpython3u;

SELECT county_name,
       trim_county(county_name)
FROM us_counties_pop_est_2019
ORDER BY state_fips, county_fips
LIMIT 5;


-- TRIGGERS
-- logging grade updates to a table
CREATE TABLE grades (
    student_id bigint,
    course_id bigint,
    course text NOT NULL,
    grade text NOT NULL,
PRIMARY KEY (student_id, course_id)
);

INSERT INTO grades
VALUES
    (1, 1, 'Biology 2', 'F'),
    (1, 2, 'English 11B', 'D'),
    (1, 3, 'World History 11B', 'C'),
    (1, 4, 'Trig 2', 'B');

CREATE TABLE grades_history (
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    change_time timestamp with time zone NOT NULL,
    course text NOT NULL,
    old_grade text NOT NULL,
    new_grade text NOT NULL,
PRIMARY KEY (student_id, course_id, change_time)
);

-- creating the function to trigger
CREATE OR REPLACE FUNCTION record_if_grade_changed()
    RETURNS trigger AS
$$
BEGIN
    IF NEW.grade <> OLD.grade THEN
    INSERT INTO grades_history (
        student_id,
        course_id,
        change_time,
        course,
        old_grade,
        new_grade)
    VALUES
        (OLD.student_id,
         OLD.course_id,
         now(),
         OLD.course,
         OLD.grade,
         NEW.grade);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- creating trigger
CREATE TRIGGER grades_update
    AFTER UPDATE
    ON grades
    FOR EACH ROW
    EXECUTE PROCEDURE record_if_grade_changed();

-- testing the trigger
UPDATE grades
SET grade = 'D'
WHERE student_id = 1 AND course_id = 1;


-- Automatically classifying temperatures
CREATE TABLE temperature_test (
    station_name text,
    observation_date date,
    max_temp integer,
    min_temp integer,
    max_temp_group text,
PRIMARY KEY (station_name, observation_date)
);

-- creating function to
CREATE OR REPLACE FUNCTION classify_max_temp()
    RETURNS trigger AS
$$
BEGIN
    CASE
       WHEN NEW.max_temp >= 90 THEN
           NEW.max_temp_group := 'Hot';
       WHEN NEW.max_temp >= 70 AND NEW.max_temp < 90 THEN
           NEW.max_temp_group := 'Warm';
       WHEN NEW.max_temp >= 50 AND NEW.max_temp < 70 THEN
           NEW.max_temp_group := 'Pleasant';
       WHEN NEW.max_temp >= 33 AND NEW.max_temp < 50 THEN
           NEW.max_temp_group := 'Cold';
       WHEN NEW.max_temp >= 20 AND NEW.max_temp < 33 THEN
           NEW.max_temp_group := 'Frigid';
       WHEN NEW.max_temp < 20 THEN
           NEW.max_temp_group := 'Inhumane';
       ELSE NEW.max_temp_group := 'No reading';
    END CASE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- creating trigger
CREATE TRIGGER temperature_insert
    BEFORE INSERT
    ON temperature_test
    FOR EACH ROW
    EXECUTE PROCEDURE
classify_max_temp();

-- insert new data to temperature_test table to see trigger of the function
-- works
INSERT INTO temperature_test
VALUES
    ('North Station', '1/19/2023', 10, -3),
    ('North Station', '3/20/2023', 28, 19),
    ('North Station', '5/2/2023', 65, 42),
    ('North Station', '8/9/2023', 93, 74),
    ('North Station', '12/14/2023', NULL, NULL);
