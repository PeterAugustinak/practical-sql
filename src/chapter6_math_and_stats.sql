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

