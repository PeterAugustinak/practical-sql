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

