/*
    helper functions that should be installed alongside the OSM import
*/

BEGIN;

 -- Inspired by http://stackoverflow.com/questions/16195986/isnumeric-with-postgresql/16206123#16206123
CREATE OR REPLACE FUNCTION as_numeric(text) RETURNS NUMERIC AS $$
DECLARE test NUMERIC;
BEGIN
     test = $1::NUMERIC;
     RETURN test;
EXCEPTION WHEN others THEN
     RETURN -1;
END;
$$ STRICT
LANGUAGE plpgsql IMMUTABLE;

COMMIT;