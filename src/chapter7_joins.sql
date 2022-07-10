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
