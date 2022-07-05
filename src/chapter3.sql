-- basic select
SELECT * FROM teachers;

-- specifying column to show
SELECT last_name, first_name, salary
FROM teachers;

-- ordering results
SELECT first_name, last_name, salary
FROM teachers
ORDER BY salary DESC;

-- ordering by column via number
SELECT first_name, last_name, salary
FROM teachers
ORDER BY 3 DESC;

-- order by multiple columns
SELECT last_name, school, hire_date
FROM teachers
ORDER BY school, hire_date DESC;

-- selecting distinct values
SELECT DISTINCT school
FROM teachers
ORDER BY school;

-- distinct pair of values
SELECT DISTINCT school, salary
FROM teachers
ORDER BY school, salary DESC;

-- filtering rows with WHERE
SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Mayers Middle School';

-- filtering using non-equal operator
SELECT school
FROM teachers
WHERE school <> 'F.D. Roosvelt HS';

-- filtering by less operator
SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2000-01-01';

-- filtering using grater than operator
SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500;

-- filtering using between operator - inclusive operator
SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000;

-- filtering between using greater/less operator
SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary >= 40000 AND salary <= 65000;

-- filtering using LIKE -> case sensitive
SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%';

-- filtering using ILIKE -> case insensitive
SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%';

-- filtering combining AND and OR operator
SELECT *
FROM teachers
WHERE school = 'Mayers Middle School' AND salary < 40000;

SELECT *
FROM teachers
WHERE last_name = 'Cole'
OR last_name = 'Bush';

-- putting it all together
SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE  school LIKE '%Roos%'
ORDER BY hire_date DESC;

-- try it yourself exercises
SELECT school, first_name, last_name
FROM teachers
ORDER BY school, last_name;

SELECT first_name, last_name, school, salary
FROM teachers
WHERE first_name LIKE 'S%'
AND salary > 40000;

SELECT first_name, last_name, hire_date, salary
FROM teachers
WHERE hire_date > '2010-01-01'
ORDER BY salary DESC;
