-- Tags: no-parallel
-- Tag no-parallel: Messes with internal cache

SET allow_experimental_query_cache = true;

SYSTEM DROP QUERY CACHE;
DROP TABLE IF EXISTS tbl;

CREATE TABLE tbl (key UInt64, agg UInt64) ENGINE = MergeTree ORDER BY key;
INSERT INTO tbl VALUES (1, 3), (2, 2), (1, 4), (1, 1);

-- A query with totals calculation. The result should written into / read from the query cache.
-- Check that both queries produce the same result.
SELECT '1st run:';
SELECT key, sum(agg) FROM tbl GROUP BY key WITH totals ORDER BY key SETTINGS use_query_cache = 1;
SELECT '2nd run:';
SELECT key, sum(agg) FROM tbl GROUP BY key WITH totals ORDER BY key SETTINGS use_query_cache = 1;

SELECT '---';

-- A query with extremes calculation. The result should written into / read from the query cache.
-- Check that both queries produce the same result.
SELECT '1st run:';
SELECT key, sum(agg) FROM tbl GROUP BY key ORDER BY key SETTINGS use_query_cache = 1, extremes = 1;
SELECT '2nd run:';
SELECT key, sum(agg) FROM tbl GROUP BY key ORDER BY key SETTINGS use_query_cache = 1, extremes = 1;

SELECT * FROM system.query_cache;

DROP TABLE IF EXISTS tbl;
SYSTEM DROP QUERY CACHE;
