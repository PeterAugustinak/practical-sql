-- extracting components from a timestamp
SELECT
    date_part('year', '2022-12-01 18:37:12 EST'::timestamptz) AS year,
    date_part('month', '2022-12-01 18:37:12 EST'::timestamptz) AS month,
    date_part('day', '2022-12-01 18:37:12 EST'::timestamptz) AS day,
    date_part('hour', '2022-12-01 18:37:12 EST'::timestamptz) AS hour,
    date_part('minute', '2022-12-01 18:37:12 EST'::timestamptz) AS minute,
    date_part('seconds', '2022-12-01 18:37:12 EST'::timestamptz) AS seconds,
    date_part('timezone_hour', '2022-12-01 18:37:12 EST'::timestamptz) AS tz,
    date_part('week', '2022-12-01 18:37:12 EST'::timestamptz) AS week,
    date_part('quarter', '2022-12-01 18:37:12 EST'::timestamptz) AS quarter,
    date_part('epoch', '2022-12-01 18:37:12 EST'::timestamptz) AS epoch;

-- using extract() to extract timestamp values
SELECT extract(year from '2022-12-01 18:37:12 EST'::timestamptz) AS year;

-- creating date with make_() function
SELECT make_date(2022, 2, 22);
SELECT make_time(18, 4, 30.3);
SELECT make_timestamptz(2022, 2, 22, 18, 4, 30.3, 'Europe/Lisbon');

-- retrieving current date and time
SELECT
    current_timestamp,
    localtimestamp,
    current_date,
    current_time,
    localtime,
    now();

-- Comparing current_timestamp and clock_timestamp() during row insert
CREATE TABLE current_time_example (
    time_id integer GENERATED ALWAYS AS IDENTITY,
    current_timestamp_col timestamptz,
    clock_timestamp_col timestamptz
);

INSERT INTO current_time_example
            (current_timestamp_col, clock_timestamp_col)
    (SELECT current_timestamp, -- time of the start transaction
            clock_timestamp() -- online time
     FROM generate_series(1,1000));

SELECT * FROM current_time_example;

-- working with timezones
SHOW timezone;
SELECT current_setting('timezone')

SELECT make_timestamptz(2022, 2, 22, 18, 4, 30.3, current_setting('timezone'));

SELECT * FROM pg_timezone_abbrevs
ORDER BY abbrev;

SELECT * FROM pg_timezone_names
WHERE name LIKE 'Europe%'
ORDER BY name;

-- setting the time zone for the client session
SET TIME ZONE 'Europe/Bratislava';

CREATE TABLE time_zone_test (
    test_date timestamptz
);
INSERT INTO time_zone_test VALUES ('2023-01-01 4:00');

SELECT test_date
FROM time_zone_test;

SET TIME ZONE 'US/Eastern';

SELECT test_date
FROM time_zone_test;

SELECT test_date AT TIME ZONE 'Asia/Seoul'
FROM time_zone_test;

-- calculations with date and times
SELECT '1929-09-30'::date - '1929-09-27'::date;
SELECT '1929-09-30'::date + '5 years'::interval;

