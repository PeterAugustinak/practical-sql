-- creating and filling library for 2018
CREATE TABLE pls_fy2018_libraries (
    stabr text NOT NULL,
    fscskey text CONSTRAINT fscskey_2018_pkey PRIMARY KEY,
    libid text NOT NULL,
    libname text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    zip text NOT NULL,
    county text NOT NULL,
    phone text NOT NULL,
    c_relatn text NOT NULL,
    c_legbas text NOT NULL,
    c_admin text NOT NULL,
    c_fscs text NOT NULL,
    geocode text NOT NULL,
    lsabound text NOT NULL,
    startdate text NOT NULL,
    enddate text NOT NULL,
    popu_lsa integer NOT NULL,
    popu_und integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl integer NOT NULL,
    video_ph integer NOT NULL,
    video_dl integer NOT NULL,
    ec_lo_ot integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    reference integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    totpro integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    obereg text NOT NULL,
    statstru text NOT NULL,
    statname text NOT NULL,
    stataddr text NOT NULL,
    longitude numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL
);

COPY pls_fy2018_libraries
FROM '/var/lib/postgresql/pls_fy2018_libraries.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX libname_2018_idx ON pls_fy2018_libraries (libname);

-- creating and filling library 2017 table
CREATE TABLE pls_fy2017_libraries (
    stabr text NOT NULL,
    fscskey text CONSTRAINT fscskey_17_pkey PRIMARY KEY,
    libid text NOT NULL,
    libname text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    zip text NOT NULL,
    county text NOT NULL,
    phone text NOT NULL,
    c_relatn text NOT NULL,
    c_legbas text NOT NULL,
    c_admin text NOT NULL,
    c_fscs text NOT NULL,
    geocode text NOT NULL,
    lsabound text NOT NULL,
    startdate text NOT NULL,
    enddate text NOT NULL,
    popu_lsa integer NOT NULL,
    popu_und integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl integer NOT NULL,
    video_ph integer NOT NULL,
    video_dl integer NOT NULL,
    ec_lo_ot integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    reference integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    totpro integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    obereg text NOT NULL,
    statstru text NOT NULL,
    statname text NOT NULL,
    stataddr text NOT NULL,
    longitude numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL
);

COPY pls_fy2017_libraries
FROM '/var/lib/postgresql/pls_fy2017_libraries.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX libname_2017_idx ON pls_fy2017_libraries (libname);

-- creating and filling library for 2016
CREATE TABLE pls_fy2016_libraries (
    stabr text NOT NULL,
    fscskey text CONSTRAINT fscskey_16_pkey PRIMARY KEY,
    libid text NOT NULL,
    libname text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    zip text NOT NULL,
    county text NOT NULL,
    phone text NOT NULL,
    c_relatn text NOT NULL,
    c_legbas text NOT NULL,
    c_admin text NOT NULL,
    c_fscs text NOT NULL,
    geocode text NOT NULL,
    lsabound text NOT NULL,
    startdate text NOT NULL,
    enddate text NOT NULL,
    popu_lsa integer NOT NULL,
    popu_und integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl integer NOT NULL,
    video_ph integer NOT NULL,
    video_dl integer NOT NULL,
    ec_lo_ot integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    reference integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    totpro integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    obereg text NOT NULL,
    statstru text NOT NULL,
    statname text NOT NULL,
    stataddr text NOT NULL,
    longitude numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL
);

COPY pls_fy2016_libraries
FROM '/var/lib/postgresql/pls_fy2016_libraries.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX libname_2016_idx ON pls_fy2016_libraries (libname);

-- counting rows and values using count()
SELECT count(*)
FROM pls_fy2018_libraries;

SELECT count(*)
FROM pls_fy2017_libraries;

SELECT count(*)
FROM pls_fy2016_libraries;

SELECT count(phone) -- if column name is in the count, NOT NULL rows are returned
FROM pls_fy2018_libraries;

-- counting distinct values in a column
SELECT count(libname)
FROM pls_fy2018_libraries;

SELECT count(DISTINCT libname)
FROM pls_fy2018_libraries;

-- finding maximum and minimum values using max() and min()
SELECT max(visits), min(visits)
FROM pls_fy2018_libraries;

SELECT visits
FROM pls_fy2018_libraries
ORDER BY visits;

-- aggregating data using GROUP BY
SELECT stabr
FROM pls_fy2018_libraries
GROUP BY stabr
ORDER BY stabr;

SELECT city, stabr
FROM pls_fy2018_libraries
GROUP BY city, stabr
ORDER BY city, stabr;

-- combining GROUP BY with count()
SELECT stabr, count(stabr)
FROM pls_fy2018_libraries
GROUP BY stabr
ORDER BY count(stabr) DESC;

-- using GROUP BY on multiple columns with count()
SELECT stabr, stataddr, count(*)
FROM pls_fy2018_libraries
GROUP BY stabr, stataddr
ORDER BY stataddr DESC, count(*) DESC;

-- using sum() to examine library activity
SELECT sum(visits) AS visits_2018
FROM pls_fy2018_libraries
WHERE visits >= 0;

SELECT sum(visits) AS visits_2017
FROM pls_fy2017_libraries
WHERE visits >= 0;

SELECT sum(visits) AS visits_2016
FROM pls_fy2016_libraries
WHERE visits >= 0;

-- joining tables to sum visits (eliminating 'artificial' data of negative visits)
SELECT sum(pls18.visits) AS visits_2018,
       sum(pls17.visits) AS visits_2017,
       sum(pls16.visits) AS visits_2016
FROM pls_fy2018_libraries pls18 JOIN pls_fy2017_libraries pls17
ON pls18.fscskey = pls17.fscskey
JOIN pls_fy2016_libraries pls16
ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0 AND pls17.visits >= 0 AND pls16.visits >= 0;

-- grouping visit sums by state
SELECT pls18.stabr,
       sum(pls18.visits) AS visits_2018,
       sum(pls17.visits) AS visits_2017,
       sum(pls16.visits) AS visits_2016,
       round((sum(pls18.visits::numeric) - sum(pls17.visits))
                 / sum(pls17.visits) * 100, 1) AS chg_2018_17,
       round((sum(pls17.visits::numeric) - sum(pls16.visits))
                 / sum(pls16.visits) * 100, 1) AS chg_2017_16
FROM pls_fy2018_libraries pls18 JOIN pls_fy2017_libraries pls17
ON pls18.fscskey = pls17.fscskey
JOIN pls_fy2016_libraries pls16
ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0 AND pls17.visits >= 0 AND pls16.visits >= 0
GROUP BY pls18.stabr
ORDER BY chg_2018_17 DESC;


-- filtering and aggregate query using HAVING
-- should be the similar as WHERE clause but applied for the GROUPS
SELECT pls18.stabr,
       sum(pls18.visits) AS visits_2018,
       sum(pls17.visits) AS visits_2017,
       sum(pls16.visits) AS visits_2016,
       round((sum(pls18.visits::numeric) - sum(pls17.visits))
                 / sum(pls17.visits) * 100, 1) AS chg_2018_17,
       round((sum(pls17.visits::numeric) - sum(pls16.visits))
                 / sum(pls16.visits) * 100, 1) AS chg_2017_16
FROM pls_fy2018_libraries pls18 JOIN pls_fy2017_libraries pls17
ON pls18.fscskey = pls17.fscskey
JOIN pls_fy2016_libraries pls16
ON pls18.fscskey = pls16.fscskey
WHERE pls18.visits >= 0 AND pls17.visits >= 0 AND pls16.visits >= 0
GROUP BY pls18.stabr
HAVING sum(pls18.visits) > 50000000
ORDER BY chg_2018_17 DESC;


-- try it yourself
-- 1. examining staff change over time
SELECT pls18.stabr,
       sum(pls18.totstaff) AS staff_2018,
       round((sum(pls18.totstaff::numeric) - sum(pls17.totstaff))
                 / sum(pls17.totstaff) * 100, 1) AS staff_chg_2018_17,
       pls17.visits AS visits_2017,
       sum(pls17.totstaff) AS staff_2017,
       round((sum(pls17.totstaff::numeric) - sum(pls16.totstaff))
                 / sum(pls16.totstaff) * 100, 1) AS staff_chg_2017_16,
       pls16.visits AS visits_2016,
       sum(pls16.totstaff) AS staff_2016
FROM pls_fy2018_libraries pls18 JOIN pls_fy2017_libraries pls17
ON pls18.fscskey = pls17.fscskey
JOIN pls_fy2016_libraries pls16
ON pls18.fscskey = pls16.fscskey
WHERE pls18.totstaff >= 0 AND pls17.totstaff >= 0 AND pls16.totstaff >= 0
GROUP BY pls18.stabr, pls17.visits, pls16.visits
HAVING sum(pls16.visits) > 100000
ORDER BY pls17.visits DESC, pls16.visits DESC, staff_chg_2018_17 DESC;

-- 2. percent change of visits grouping obereg
-- just check if all years have the same number of obereg
SELECT count(DISTINCT pls18.obereg) AS obereg_2018,
       count(DISTINCT pls17.obereg) AS obereg_2017,
       count(DISTINCT pls16.obereg) AS obereg_2016
FROM pls_fy2018_libraries pls18 JOIN pls_fy2017_libraries pls17
ON pls18.fscskey = pls17.fscskey
JOIN pls_fy2016_libraries pls16
ON pls18.fscskey = pls16.fscskey
ORDER BY count(DISTINCT pls18.obereg) DESC;

-- create new table to map obereg codes to names
CREATE TABLE obereg (
    obereg text CONSTRAINT obereg_key PRIMARY KEY,
    region_name text);

INSERT INTO obereg (obereg, region_name)
VALUES
    ('01', 'New England'),
    ('02', 'Mid East'),
    ('03', 'Great Lakes'),
    ('04', 'Plains'),
    ('05', 'Southeast'),
    ('06', 'Southwest'),
    ('07', 'Rocky Mountains'),
    ('08', 'Far West'),
    ('09', 'Outlying Areas');

SELECT pls18.obereg AS library_agency,
       obereg.region_name AS region_name,
       sum(pls18.visits) AS visits_2018,
       round((sum(pls18.visits::numeric) - sum(pls17.visits))
                 / sum(pls17.visits) * 100, 1) AS chg_2018_17,
       sum(pls17.visits) AS visits_2017,
       round((sum(pls17.visits::numeric) - sum(pls16.visits))
                 / sum(pls16.visits) * 100, 1) AS chg_2017_16,
       sum(pls16.visits) AS visits_2016
FROM pls_fy2018_libraries pls18 JOIN pls_fy2017_libraries pls17
ON pls18.fscskey = pls17.fscskey
JOIN pls_fy2016_libraries pls16
ON pls18.fscskey = pls16.fscskey
JOIN obereg
ON pls18.obereg = obereg.obereg
WHERE pls18.visits >= 0 AND pls17.visits >= 0 AND pls16.visits >= 0
GROUP BY pls18.obereg, obereg.region_name
ORDER BY chg_2018_17 DESC;

-- 3. find agencies missing in the tables
SELECT pls18.obereg,
       pls17.obereg,
       pls16.obereg
FROM pls_fy2018_libraries pls18 FULL OUTER JOIN pls_fy2017_libraries pls17
USING (fscskey)
FULL OUTER JOIN pls_fy2016_libraries pls16
USING (fscskey)
WHERE pls18.obereg IS NULL OR pls17.obereg IS NULL OR pls16.obereg IS NULL
GROUP BY pls18.obereg, pls17.obereg, pls16.obereg;
