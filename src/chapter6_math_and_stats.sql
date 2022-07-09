-- adding, subtracting, multiplying
SELECT 2 + 2 AS add;
SELECT 9 + 1 AS subtract;
SELECT 3 * 4 AS multiply;

-- division and modulo
SELECT 11 / 6 AS divide;
SELECT 11 % 6 AS modulo;
SELECT 11.0 / 6 AS divide_decimal;
SELECT CAST(11 AS numeric(3, 1)) / 6 AS divide_using_cast;

-- exponents, roots and factorial
SELECT 3 ^ 4 AS exponent;
SELECT |/ 10 AS square;
SELECT sqrt(10) AS square_func;
SELECT ||/ 10 AS cube_root;
SELECT 4! AS factorial; -- not working in postgres 14 and higher
SELECT factorial(4) AS factorial_func;
SELECT 3 ^ (SELECT ||/ 10) AS exponent_using_another_select;

/*
 Order:
 exponents and roots
 multiplication, division, modulo
 addition, and subtraction
 */

SELECT 7 + 8 * 9;
SELECT (7 + 8) * 9;

SELECT 3 ^ 3 - 1 ;
SELECT 3 ^ (3 - 1);

-- math across census table
SELECT county_name AS county,
       state_name AS state,
       pop_est_2019 AS pop,
       births_2019 AS births,
       deaths_2019 AS deaths,
       international_migr_2019 AS int_migr,
       domestic_migr_2019 AS dom_migr,
       residual_2019 AS residual
FROM us_counties_pop_est_2019;

-- adding and subtracting columns
SELECT county_name AS county,
       state_name AS state,
       births_2019 AS births,
       deaths_2019 AS deaths,
       births_2019 - deaths_2019 AS natural_increase
FROM us_counties_pop_est_2019
ORDER BY natural_increase DESC;

-- verifier
SELECT county_name AS county,
       state_name AS state,
       pop_est_2019 AS pop,
       pop_est_2018 + births_2019 - deaths_2019 + international_migr_2019 +
       residual_2019 AS components_total,
       pop_est_2019 - (pop_est_2018 + births_2019 - deaths_2019 +
                       international_migr_2019 + domestic_migr_2019 +
                       residual_2019) AS difference
FROM us_counties_pop_est_2019
ORDER BY difference DESC;

-- finding percentage of a whole
SELECT county_name AS county,
       state_name as state,
       area_land AS land,
       area_water AS water,
       area_water::numeric / (area_land + area_water) * 100 AS pct_water
FROM us_counties_pop_est_2019
ORDER BY pct_water DESC;

-- tracking percent change
CREATE TABLE percent_change (
    department text,
    spend_2019 numeric(10,2),
    spend_2022 numeric(10,2)
);

INSERT INTO percent_change
VALUES
    ('Assessor', 178556, 179500),
    ('Building', 250000, 289000),
    ('Clerk', 451980, 650000),
    ('Library', 87777, 90001),
    ('Parks', 250000, 223000),
    ('Water', 199000, 195000);

SELECT department,
       spend_2019,
       spend_2022,
       round( (spend_2022 - spend_2019) /
                    spend_2019 * 100, 1) AS pct_change
FROM percent_change;

-- aggregate functions for averages and sums
SELECT sum(pop_est_2019) AS county_sum,
       round(avg(pop_est_2019), 0) AS county_average
FROM us_counties_pop_est_2019;

-- median
/*
 Average - the sum of all values divided by the number of values
 Median - the "middle" value in an ordered set of values
 */

-- finding the median with percentile functions
CREATE TABLE percentile_test (numbers integer);

INSERT INTO percentile_test (numbers)
VALUES (1), (2), (3), (4), (5), (6);

SELECT
    percentile_cont(.5)
        WITHIN GROUP (ORDER BY numbers),
    percentile_disc(.5)
        WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

-- finding median and percentiles with census data
SELECT sum(pop_est_2019) AS county_sum,
       round(avg(pop_est_2019), 0) AS county_average,
       percentile_disc(.5)
           WITHIN GROUP (ORDER BY pop_est_2019) AS county_median
FROM us_counties_pop_est_2019;

-- finding other quantiles with percentile functions
SELECT percentile_cont(ARRAY[.25, .5, .75])
WITHIN GROUP (ORDER BY pop_est_2019) AS quartiles
FROM us_counties_pop_est_2019;

-- make resulted array to separate rows
SELECT unnest(
            percentile_cont(ARRAY[.25,.5,.75])
            WITHIN GROUP (ORDER BY pop_est_2019)
            ) AS quartiles
FROM us_counties_pop_est_2019;

-- finding the mode - value that appears most often
SELECT mode() WITHIN GROUP (ORDER BY births_2019)
FROM us_counties_pop_est_2019;


-- try it yourself exercises
-- area of circle
SELECT PI() * 5 AS circle_area;

-- ratio birth to deaths
SELECT county_name AS county,
       births_2019 AS births,
       deaths_2019 AS deaths,
       births_2019 + deaths_2019 AS total,
       births_2019::numeric / ((births_2019 + 1) + (deaths_2019 + 1)) * 100
           AS births_ratio
FROM us_counties_pop_est_2019
ORDER BY births_ratio;

SELECT births_2019 FROM us_counties_pop_est_2019 ORDER BY births_2019;
SELECT deaths_2019 FROM us_counties_pop_est_2019 ORDER BY deaths_2019;

-- was the median county population higher in California or New York?
SELECT
    percentile_cont(.5)
        WITHIN GROUP (ORDER BY pop_est_2019)
FROM us_counties_pop_est_2019
WHERE state_name = 'California';

SELECT
    percentile_cont(.5)
        WITHIN GROUP (ORDER BY pop_est_2019)
FROM us_counties_pop_est_2019
WHERE state_name = 'New York';
