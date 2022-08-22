-- VACUUM for cleaning unused space
CREATE TABLE vacuum_test (integer_column integer);
SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));

-- check table withib size
\dt+ vacuum_test

INSERT INTO vacuum_test SELECT * FROM generate_series(1, 5000000);

UPDATE vacuum_test SET integer_column = integer_column + 1;

SELECT relname,
       last_vacuum,
       last_autovacuum,
       vacuum_count,
       autovacuum_count
FROM pg_stat_all_tables WHERE relname = 'vacuum_test';

-- running vacuum manually
VACUUM vacuum_test;

-- reducing table size with full vacuum
VACUUM FULL vacuum_test;

SELECT * FROM vacuum_test ORDER BY integer_column DESC;


-- CHANGING SERVER SETTINGS
SHOW config_file ;
-- #autovacuum = on for autovacuum settings

-- RELOADING settings with pg_ctl
SHOW data_directory ;

-- pg_ctl reload /var/lib/postgresql/data/pgdata


-- BACKING UP AND RESTORING
-- back up all db
pg_dump -d analysis -U test -Fc -v -f analysis_backup.dump

-- back up one table
pg_dump -t 'train_rides' -d analysis -U test -Fc -v -f train_backup.dump

-- restore db
pg_restore -C -v -d postgres -U test analysis_backup.dump

DELETE FROM train_rides;
SELECT * FROM train_rides;
pg_restore -t 'train_rides' -C -v -d postgres -U test analysis_backup.dump

DROP table train_rides;
