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

-- updating values accross tables
