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



