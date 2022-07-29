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


