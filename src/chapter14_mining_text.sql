-- formatting text using string functions
-- case formatting
SELECT upper('hello');
SELECT lower('Randy');
SELECT initcap('at the end of the day');

-- character information
SELECT char_length(' Pat '); -- 5
SELECT length('Pat'); -- 3
SELECT position(', ' in 'Tan, Bella'); -- no 0 index

-- removing characters
SELECT trim('s' from 'socks');
SELECT trim(trailing 's' from 'socks');
SELECT trim(' Pat ');
SELECT char_length(trim(' Pat ')); -- note the length change
SELECT ltrim('socks', 's');
SELECT rtrim('socks', 's');

-- Extracting and replacing characters
SELECT left('703-555-1212', 3);
SELECT right('703-555-1212', 8); -- means last 8 chars
SELECT replace('bat', 'b', 'c');

/*
 . - any character
 \w - word character
 \d - digit
 ? - 0 or 1 time
 * - 1 or more times
 + - 1 or more times
 ^ - at the start
 & - at the end
 */

-- Regular expressions
-- Any character one or more times
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '.+');
-- One or two digits followed by a space and a.m. or p.m. in a noncapture group
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\d{1,2} (?:a.m.|p.m.)');
-- One or more word characters at the start
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '^\w+');
-- One or more word characters followed by any character at the end.
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\w+.$');
-- The words May or June
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from 'May|June');
-- Four digits
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\d{4}');
-- May followed by a space, digit, comma, space, and four digits.
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from 'May \d, \d{4}');

-- using regular expression with WHERE
SELECT county_name
FROM us_counties_pop_est_2019
WHERE county_name ~* '(lade|lare)' -- matches all counties containing 'lade' or 'lare'
ORDER BY county_name;

SELECT county_name
FROM us_counties_pop_est_2019
WHERE county_name ~* 'ash' AND county_name !~* 'Wash' -- all containing 'ash' but not 'Wash'
ORDER BY county_name;

-- regular expression FUNCTIONS to replace or split text
SELECT regexp_replace('05/12/2024', '\d{4}', '2023');
SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',') AS split;
SELECT regexp_split_to_array('Phil Mike Tony Steve', ' ');
-- length of array, 1 means length of first dimension if there is more
SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);


-- turning text into data using regular expression functions
CREATE TABLE crime_reports (
    crime_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    case_number text,
    date_1 timestamptz,
    date_2 timestamptz,
    street text,
    city text,
    crime_type text,
    description text,
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM '/var/lib/postgresql/crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

-- first date
SELECT crime_id,
       regexp_match(original_text,
           '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports
ORDER BY crime_id;

-- second date (match vs matches with 'g' - return every match as a row
SELECT crime_id,
       regexp_matches(original_text,
           '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports
ORDER BY crime_id;

SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
       CASE WHEN EXISTS (SELECT regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})'))
            THEN regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})')
            ELSE NULL
            END AS date_2,
       regexp_match(original_text, '\/\d{2}\n(\d{4})') AS hour_1,
       CASE WHEN EXISTS (SELECT regexp_matches(original_text, '\/\d{2}\n\d{4}-(\d{4})'))
            THEN regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})')
            ELSE NULL
            END AS hour_2,
       regexp_match(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))') AS street,
       regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') AS city,
       regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
       regexp_match(original_text, ':\s(.+)(?:C0|SO)') AS description,
       regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number
FROM crime_reports
ORDER BY crime_id;

-- retrieving value from within an array
SELECT
    crime_id,
    (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1]
        AS case_number
FROM crime_reports
ORDER BY crime_id;