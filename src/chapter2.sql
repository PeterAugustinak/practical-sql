CREATE DATABASE analysis;

CREATE TABLE teachers (
	id bigserial,
	first_name varchar(25),
	last_name varchar(50),
	school varchar(50),
	hire_date date,
	salary numeric
);

INSERT INTO teachers
	(first_name, last_name, school, hire_date, salary)
VALUES
	('Janet', 'Smith', 'F.D. Roosvelt HS', '2011-10-30', 36200),
	('Lee', 'Reynolds', 'F.D. Roosvelt HS', '1993-05-22', 65000),
	('Samuel', 'Cole', 'Mayers Mdle School', '2005-05-22', 65000),
	('Samantha', 'Bush', 'Mayers Middle School', '2011-10-30', 36200),
	('Betty', 'Diaz', 'Mayers Middle School', '2005-08-30', 43500),
	('Kathleen', 'Roush', 'F.D. Roosvelt HS', '2010-10-22', 38500);


SELECT * FROM teachers;