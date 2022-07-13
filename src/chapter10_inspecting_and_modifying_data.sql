-- create table for inspecting and modifying data
CREATE TABLE meat_poultry_egg_establishments (
    establishment_number text CONSTRAINT est_number_key PRIMARY KEY ,
    company text,
    street text,
    city text,
    st text,
    zip text,
    phone text,
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_establishments
FROM '/var/lib/postgresql/MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX company_idx
ON meat_poultry_egg_establishments (company);

-- check imported data are all
SELECT count(*)
FROM meat_poultry_egg_establishments;

-- interviewing dataset - look if there is more than 1 combination of address
SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;

-- LOOKING FOR INCORRECT DATA
-- do we have values for all states, missing any rows a state code?
-- how many meat, poultry and egg processing are there in each state?
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_establishments
GROUP BY st
ORDER BY st;

-- missing ST code values - checking 3 entries where st is missing
SELECT establishment_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;

-- incorrect COMPANY name form - checking for inconsistent data values
SELECT company,
       count(*) AS company_count
FROM meat_poultry_egg_establishments
GROUP BY company
ORDER BY company;

-- incorrect ZIP code length - checking malformed values using length()
SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_establishments
GROUP BY length(zip)
ORDER BY length(zip);

-- how many of the ZIP are incorrect for particular state
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5
GROUP BY st
ORDER BY st;


-- MODIFYING TABLES, COLUMNS AND DATA
-- fixing above errors

-- modifying TABLES (definition) with ALTER TABLE
/*
 ALTER TABLE table ADD COLUMN column, data_type;
 ALTER TABLE table DROP COLUMN column;
 ALTER TABLE table LATER COLUMN column SET DATA TYPE data_type;
 ALTER TABLE table ALTER COLUMN column SET NOT NULL;
 ALTER TABLE table ALTER COLUMN column DROP NOT NULL;
 */

-- modifying VALUES with UPDATE
/*
 UPDATE table
 SET column = value;

 UPDATE table
 SET column_a = value,
     column_b = value;

 UPDATE table
 SET column = value
 WHERE criteria;

 -- update table a with values from table b
 UPDATE table
 SET column = (SELECT column
               FROM table_b
               WHERE table.column = table_b.column)
 WHERE EXISTS (SELECT column
               FROM table_b
               WHERE table.column = table_b.column);

 -- same as above but postgres implementation:
 UPDATE table
 SET column = table_b.column
 FROM table_b
 WHERE table.column = table_b.column;
 */

/*
viewing modified data with RETURNING (postgres specific)
 UPDATE table
 SET column_a = value
 RETURNING column_a, column_b, column_c;
 */

-- creating table backups
CREATE TABLE meat_poultry_egg_establishments_backup AS
    SELECT * FROM meat_poultry_egg_establishments;

-- check count rows if backup was successful
SELECT (SELECT count(*) FROM meat_poultry_egg_establishments) AS original,
       (SELECT count(*) FROM meat_poultry_egg_establishments_backup AS backup);

-- creating a column copy
ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN st_copy text;

-- update this column with the values of original column
UPDATE meat_poultry_egg_establishments
SET st_copy = st;

-- check if the column copy was successful
SELECT st,
       st_copy
FROM meat_poultry_egg_establishments
WHERE st IS DISTINCT FROM meat_poultry_egg_establishments.st_copy
ORDER BY st;


-- updating rows where values are missing
SELECT establishment_number,
       st
FROM meat_poultry_egg_establishments
WHERE st IS NULL;

UPDATE meat_poultry_egg_establishments
SET st = 'MN'
WHERE establishment_number = 'V18677A';

UPDATE meat_poultry_egg_establishments
SET st = 'AL'
WHERE establishment_number = 'M45319+P45319';

UPDATE meat_poultry_egg_establishments
SET st = 'WI'
WHERE establishment_number = 'M263A+P263A+V263A';

-- check if st values were updated successfully
SELECT st,
       establishment_number
FROM meat_poultry_egg_establishments
WHERE establishment_number IN ('V18677A', 'M45319+P45319', 'M263A+P263A+V263A');

-- restoring original values
-- from column backup
UPDATE meat_poultry_egg_establishments
SET st = st_copy;

-- from table meat_poultry_egg_establishments_backup
UPDATE meat_poultry_egg_establishments original
SET st = backup.st
FROM meat_poultry_egg_establishments_backup backup
WHERE original.establishment_number = backup.establishment_number;

-- updating values for consistency
SELECT DISTINCT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'Armour%';

-- adding column for updating operation (to backup original column)
ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN company_standard text;

-- filling copied column with values
UPDATE meat_poultry_egg_establishments
SET company_standard = company;

-- update column with standardized name for specific company
UPDATE meat_poultry_egg_establishments
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%'
RETURNING company, meat_poultry_egg_establishments.company_standard;

-- verifying the company has the standard name now
SELECT DISTINCT meat_poultry_egg_establishments.company_standard
FROM meat_poultry_egg_establishments
WHERE company LIKE 'Armour%';

-- repairing ZIP code using concatenation
ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN zip_copy text;

UPDATE meat_poultry_egg_establishments
SET zip_copy = zip;

-- list all short zips grouped by st
SELECT st, length(zip) AS length_zip
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5
GROUP BY st, length_zip
ORDER BY length(zip) DESC;


-- update 3 char long zips
UPDATE meat_poultry_egg_establishments
SET zip = '00' || zip
WHERE st IN ('PR', 'VI') AND length(zip) = 3
RETURNING st, zip;

-- update 4 char long zips
UPDATE meat_poultry_egg_establishments
SET zip = '0' || zip
WHERE st IN ('CT', 'MA', 'ME', 'NH', 'NJ', 'RI', 'VT') AND length(zip) = 4
RETURNING st, zip;

SELECT st, zip
FROM meat_poultry_egg_establishments
WHERE length(zip) < 5;

-- updating values across tables
-- create new table with state regions
CREATE TABLE state_regions (
    st text CONSTRAINT st_key PRIMARY KEY,
    region text NOT NULL
);

COPY state_regions
FROM '/var/lib/postgresql/state_regions.csv'
WITH (FORMAT CSV, HEADER);

-- adding new column to meat table
ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN inspection_deadline timestamp with time zone;

-- updating the column with default data based on values from another table
UPDATE meat_poultry_egg_establishments establishments
SET inspection_deadline = '2022-12-01 00:00 EST'
WHERE EXISTS (
    SELECT state_regions.region
    FROM state_regions
    WHERE establishments.st = state_regions.st
    AND state_regions.region = 'New England');

-- checking around
SELECT e.st, inspection_deadline
FROM meat_poultry_egg_establishments e
JOIN state_regions streg
ON e.st = streg.st
WHERE streg.region = 'New England';

SELECT region, count(region)
FROM state_regions
GROUP BY region
ORDER BY count(region);

SELECT *
FROM state_regions
WHERE region = 'New England';

SELECT st, inspection_deadline
FROM meat_poultry_egg_establishments
GROUP BY st, meat_poultry_egg_establishments.inspection_deadline
ORDER BY st;


-- deleting unneeded data
/*
 deleting all rows from a table:
 DELETE FROM table_name;

 deleting specific rows from a table
 DELETE FROM table_name WHERE expression;

 deleting all rows - faster
 TRUNCATE table_name;

 deleting all rows plus possibility to restart IDENTITY:
 TRUNCATE table_name RESTART IDENTITY;

 deleting column from a table
 ALTER TABLE table_name DROP COLUMN column_name;

 deleting table from a database:
 DROP TABLE table_name;
 */

DELETE FROM meat_poultry_egg_establishments
WHERE st IN ('AS', 'GU', 'MP', 'PR', 'VI');

ALTER TABLE meat_poultry_egg_establishments
DROP COLUMN zip_copy;

DROP TABLE meat_poultry_egg_establishments_backup;

-- using transaction to save revert changes
START TRANSACTION;

UPDATE meat_poultry_egg_establishments
SET company = 'AGRO Merchantss Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

SELECT company
FROM meat_poultry_egg_establishments
WHERE company LIKE 'AGRO%'
ORDeR BY company;

ROLLBACK;


-- improving performance when updating large tables
-- creating new (backup) table with adding new column with default value
CREATE TABLE meat_poultry_establishments_backup AS
    SELECT  *, '2023-02-14 00:00 EST'::timestamp with time zone AS reviewed_date
    FROM meat_poultry_egg_establishments;

-- swap table names
ALTER TABLE meat_poultry_egg_establishments RENAME TO meat_temp;
ALTER TABLE meat_poultry_egg_establishments_backup RENAME TO meat_poultry_egg_establishments;
ALTER TABLE meat_temp RENAME TO meat_poultry_egg_establishments_backup;


-- try it yourself exercises
SELECT activities, count(activities)
FROM meat_poultry_egg_establishments
GROUP BY activities;

-- 1. two new boolean columns
ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN meat_processing boolean;

ALTER TABLE meat_poultry_egg_establishments
ADD COLUMN poultry_processing boolean;

-- 2. update new columns based on particular activity
UPDATE meat_poultry_egg_establishments
SET meat_processing = TRUE
WHERE activities LIKE '%Meat Processing%';

UPDATE meat_poultry_egg_establishments
SET poultry_processing = TRUE
WHERE activities LIKE '%Poultry Processing%';

SELECT activities, meat_processing, poultry_processing
FROM meat_poultry_egg_establishments
WHERE meat_processing = TRUE OR poultry_processing = TRUE;

-- 3. how many plant perform each activity and how many both
SELECT (
    (SELECT count(meat_processing) AS processing_meat
            FROM meat_poultry_egg_establishments
            WHERE meat_processing = TRUE),
    (SELECT count(poultry_processing) AS processing_poultry
            FROM meat_poultry_egg_establishments
            WHERE poultry_processing = TRUE),
    (SELECT count(meat_processing) + count(poultry_processing) AS processing_both
            FROM meat_poultry_egg_establishments
            WHERE meat_processing = TRUE AND poultry_processing = TRUE));


SELECT activities
FROM meat_poultry_egg_establishments
WHERE poultry_processing IS NULL AND meat_processing IS NULL
GROUP BY activities;
