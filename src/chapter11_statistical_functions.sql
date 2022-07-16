-- creating a Census Stats table
CREATE TABLE acs_2014_2018_stats (
    geoid text CONSTRAINT geoid_key PRIMARY KEY,
    county text NOT NULL,
    st text NOT NULL,
    pct_travel_60_min numeric(5, 2),
    pct_bachelors_higher numeric(5, 2),
    pct_masters_higher numeric(5, 2),
    median_hh_income integer,
    CHECK (pct_masters_higher <= pct_bachelors_higher)
);

COPY acs_2014_2018_stats
FROM '/var/lib/postgresql/acs_2014_2018_stats.csv'
WITH (FORMAT CSV, HEADER );

SELECT *
FROM acs_2014_2018_stats
ORDER BY median_hh_income DESC;

-- correlation
SELECT corr(median_hh_income, pct_bachelors_higher)
AS bachelors_income_r
FROM acs_2014_2018_stats;

-- additional correlation
SELECT
    round(
        corr(median_hh_income, pct_bachelors_higher):: numeric, 2)
        AS bachelors_income_r,
    round(
        corr(pct_travel_60_min, median_hh_income)::numeric, 2)
        AS income_travel_r,
    round(
        corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2)
        AS bachelors_travel_r
FROM acs_2014_2018_stats;


-- predicting values with regression analysis
SELECT
    round(
        regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2)
        AS slope,
    round(
        regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2)
        AS y_intercept
 FROM acs_2014_2018_stats;

-- finding the effect of an independent variable with r-squared
SELECT round(
    regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3)
    AS r_squared
FROM acs_2014_2018_stats;


-- rankings
CREATE TABLE widget_companies (
    id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    company text NOT NULL,
    widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
    ('Dom Widgets', 125000),
    ('Ariadne Widget Masters', 143000),
    ('Saito Widget Co.', 201000),
    ('Mal Inc.', 133000),
    ('Dream Widget Inc.', 196000),
    ('Miles Amalgamated', 620000),
    ('Arthur Industries', 244000),
    ('Fischer Worldwide', 201000);

SELECT company,
       widget_output,
       rank() OVER (ORDER BY widget_output DESC),
       dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies
ORDER BY widget_output DESC;

-- ranking within subrgroups with PARTITION BY
CREATE TABLE store_sales (
    store text NOT NULL,
    category text NOT NULL,
    unit_sales bigint NOT NULL,
    CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
    ('Broders', 'Cereal', 1104),
    ('Wallace', 'Ice Cream', 1863),
    ('Broders', 'Ice Cream', 2517),
    ('Cramers', 'Ice Cream', 2112),
    ('Broders', 'Beer', 641),
    ('Cramers', 'Cereal', 1003),
    ('Cramers', 'Beer', 640),
    ('Wallace', 'Cereal', 980),
    ('Wallace', 'Beer', 988);

SELECT category,
       store,
       unit_sales,
       rank() OVER (PARTITION BY category ORDER BY unit_sales DESC)
FROM store_sales
ORDER BY category, rank() OVER (
    PARTITION BY category ORDER BY unit_sales DESC);

-- calculating rates for meaningful comparisons
-- finding rates of tourism-related businesses
CREATE TABLE cbp_naics_72_establishments (
    state_fips text,
    county_fips text,
    county text NOT NULL,
    st text NOT NULL,
    naics_2017 text NOT NULL,
    naics_2017_label text NOT NULL,
    year smallint NOT NULL,
    establishments integer NOT NULL,
    CONSTRAINT cbp_fips_key PRIMARY KEY (state_fips, county_fips)
);

COPY cbp_naics_72_establishments
FROM '/var/lib/postgresql/cbp_naics_72_establishments.csv'
WITH (FORMAT CSV, HEADER);

SELECT *
FROM cbp_naics_72_establishments
ORDER BY state_fips, county_fips
LIMIT 5;

SELECT cbp.county,
       cbp.st,
       cbp.establishments,
       pop.pop_est_2018,
       round(
           (cbp.establishments::numeric / pop.pop_est_2018) * 1000, 1)
           AS estabs_per_1000
FROM cbp_naics_72_establishments cbp JOIN us_counties_pop_est_2019 pop
ON cbp.state_fips = pop.state_fips
AND cbp.county_fips = pop.county_fips
WHERE pop.pop_est_2018 >= 50000
ORDER BY cbp.establishments::numeric / pop.pop_est_2018 DESC;


-- smoothing uneven data
CREATE TABLE us_exports (
    year smallint,
    month smallint,
    citrus_export_value bigint,
    soybeans_export_value bigint);

COPY us_exports
FROM '/var/lib/postgresql/us_exports.csv'
WITH (FORMAT CSV, HEADER);

SELECT year, month, citrus_export_value
FROM us_exports
ORDER BY year, month;

SELECT year, month, citrus_export_value,
       round(
           avg(citrus_export_value)
               OVER(ORDER BY year, month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 0)
       AS twelve_month_avg
FROM us_exports
ORDER BY year, month;


-- try it yourself
-- 1. correlation between income and masters -> value is lower
SELECT corr(median_hh_income, pct_masters_higher)
AS masters_income_r
FROM acs_2014_2018_stats;

-- 2. soybean 12 months
SELECT year, month, soybeans_export_value,
       round(
           avg(soybeans_export_value)
               OVER(ORDER BY year, month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 0)
       AS twelve_month_avg_soybeans
FROM us_exports
ORDER BY year, month;

-- libraries visit per 1000 - incorrect
SELECT lib.county,
       lib.libname,
       pop.pop_est_2018,
       round(
           (lib.popu_lsa::numeric / pop.pop_est_2018) * 1000, 1)
           AS estabs_per_1000
FROM pls_fy2018_libraries lib JOIN us_counties_pop_est_2019 pop
ON lib.county = pop.county_name
ORDER BY lib.popu_lsa::numeric / pop.pop_est_2018 DESC;
