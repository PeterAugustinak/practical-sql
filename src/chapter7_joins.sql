/*
 form:
 SELECT *
 FROM table_a JOIN table_b
 ON table_a.key_column = table_b.foreign_key_column
 */

-- creating departments + employees table for test joins
 CREATE TABLE departments (
    dept_id integer,
    dept text,
    city text,
    CONSTRAINT dept_key PRIMARY KEY (dept_id),
    CONSTRAINT dept_city_unique UNIQUE (dept, city)
);

CREATE TABLE employees (
    emp_id integer,
    first_name text,
    last_name text,
    salary numeric(10,2),
    dept_id integer REFERENCES departments (dept_id),
    CONSTRAINT emp_key PRIMARY KEY (emp_id)
);

INSERT INTO departments
VALUES
    (1, 'Tax', 'Atlanta'),
    (2, 'IT', 'Boston');

INSERT INTO employees
VALUES
    (1, 'Julia', 'Reyes', 115300, 1),
    (2, 'Janet', 'King', 98000, 1),
    (3, 'Arthur', 'Pappas', 72700, 2),
    (4, 'Michael', 'Taylor', 89500, 2);

SELECT * FROM departments;
SELECT * FROM employees;

-- querying multiple tables using JOIN
SELECT *
FROM departments JOIN employees
ON departments.dept_id = employees.dept_id
ORDER BY employees.dept_id;

-- different types of JOIN
CREATE TABLE district_2020 (
    id integer CONSTRAINT id_key_2020 PRIMARY KEY,
    school_2020 text
);

CREATE TABLE district_2035 (
    id integer CONSTRAINT id_key_2035 PRIMARY KEY,
    school_2035 text
);

INSERT INTO district_2020 VALUES
    (1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (5, 'Dover Middle School'),
    (6, 'Webutuck High School');

INSERT INTO district_2035 VALUES
    (1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (3, 'Morrison Elementary'),
    (4, 'Chase Magnet Academy'),
    (6, 'Webutuck High School');

SELECT * FROM district_2020;
SELECT * FROM district_2035;

/*
INNER JOIN (or JOIN)
 to return only rows from both tables with value where columns matches
 */
SELECT *
FROM district_2020 INNER JOIN district_2035
ON district_2020.id = district_2035.id
ORDER BY district_2020.id;

-- JOIN with USING (in case of column names using for join in both tables are the same)
SELECT *
FROM district_2020 JOIN district_2035
USING (id)
ORDER BY district_2020.id;

/*
LEFT JOIN and RIGHT JOIN
 to return all rows from left (right) table regardless it has value in
 right (left) table
 */
SELECT *
FROM district_2020 LEFT JOIN district_2035
USING (id)
ORDER BY district_2020.id;

SELECT *
FROM district_2020 RIGHT JOIN district_2035
USING (id)
ORDER BY district_2035.id;

/*
 FULL OUTER JOIN
 - to return all rows from both tables regardless if value is present
 */
SELECT *
FROM district_2020 FULL OUTER JOIN district_2035
USING (id)
ORDER BY district_2020.id;

/*
 CROSS JOIN
 - to return all possible combination (Cartesian product)
  */
SELECT *
FROM district_2020 CROSS JOIN district_2035
ORDER BY district_2020.id, district_2035.id;

-- using NULL to find rows with missing values
SELECT *
FROM district_2020 LEFT JOIN district_2035
USING (id)
WHERE district_2035.id IS NULL;
-- WHERE district_2035 IS NOT NULL;

-- selecting specific columns in a JOIN
SELECT id -- possible as the column id is present in both tables
FROM district_2020 LEFT JOIN district_2035
USING (id);

SELECT district_2020.id,
       district_2020.school_2020,
       district_2035.school_2035
FROM district_2020 LEFT JOIN district_2035
USING (id)
ORDER BY district_2020.id;

-- simplifying JOIN syntax with table aliases
SELECT d20.id,
       d20.school_2020,
       d35.school_2035
FROM district_2020 AS d20 LEFT JOIN district_2035 AS d35
ON d20.id = d35.id
ORDER BY d20.id;

-- joining multiple tables
CREATE TABLE district_2020_enrollment (
    id integer,
    enrollment integer
);

CREATE TABLE district_2020_grades (
    id integer,
    grades varchar(10)
);

INSERT INTO district_2020_enrollment
VALUES
    (1, 360),
    (2, 1001),
    (5, 450),
    (6, 927);

INSERT INTO district_2020_grades
VALUES
    (1, 'K-3'),
    (2, '9-12'),
    (5, '6-8'),
    (6, '9-12');

SELECT * FROM district_2020_enrollment;
SELECT * FROM district_2020_grades;

SELECT d20.id,
       d20.school_2020,
       en.enrollment,
       gr.grades
FROM district_2020 AS d20
JOIN district_2020_enrollment AS en
    ON d20.id = en.id
JOIN district_2020_grades AS gr
    ON d20.id = gr.id
ORDER BY d20.id;

-- combining query result with set operators
/*
 UNION - append results from two queries, removes duplicates, distinct rows
 UNION ALL - all results including duplicates
 INTERSECT - returns only rows exist in the results of both, removing duplicates
 EXCEPT - returns result exist in first query but not in the second query, duplicates removed
 */

-- UNION
SELECT * FROM district_2020
UNION
SELECT * FROM district_2035
ORDER BY id;

-- UNION ALL
SELECT * FROM district_2020
UNION ALL
SELECT * FROM district_2035
ORDER BY id;

-- customizing result by adding "default" column to inform about table
SELECT '2020' AS year,
       school_2020 AS school
FROM district_2020
UNION ALL
SELECT '2035' AS year,
       school_2035
FROM district_2035
ORDER BY year, school;

-- INTERSECT
SELECT * FROM district_2020
INTERSECT
SELECT * FROM district_2035
ORDER BY id;

-- EXCEPT
SELECT * FROM district_2020
EXCEPT
SELECT * FROM district_2035
ORDER BY id;

-- performing math in JOINed table columns

