-- json -> as text, ordered
-- jsonb - binary, removing white spaces, not ordered


CREATE TABLE  films
(
    id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    film jsonb NOT NULL
);

COPY films (film)
FROM '/var/lib/postgresql/films.json';

SELECT * FROM films;

