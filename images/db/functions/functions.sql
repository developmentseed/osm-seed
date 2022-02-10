--------------------------------------------------------------------------------
-- From https://github.com/openstreetmap/openstreetmap-website/blob/af273f5d6ae160de0001ce1ac0c087d92a2463c6/db/functions/functions.sql
-- SQL versions of the C database functions.
--
-- Pure pl/pgsql versions are *slower* than the C versions, and not recommended
-- for production use. However, they are significantly easier to install, and
-- require fewer dependencies.
--------------------------------------------------------------------------------

-- tile_for_point function returns a Morton-encoded integer representing a z16
-- tile which contains the given (scaled_lon, scaled_lat) coordinate. Note that
-- these are passed into the function as (lat, lon) and should be scaled by
-- 10^7.
--
-- The Morton encoding packs two dimensions down to one with fairly good
-- spatial locality, and can be used to index points without the need for a
-- proper 2D index.
CREATE OR REPLACE FUNCTION tile_for_point(scaled_lat int4, scaled_lon int4)
  RETURNS int8
  AS $$
DECLARE
  x int8; -- quantized x from lon,
  y int8; -- quantized y from lat,
BEGIN
  x := round(((scaled_lon / 10000000.0) + 180.0) * 65535.0 / 360.0);
  y := round(((scaled_lat / 10000000.0) +  90.0) * 65535.0 / 180.0);

  -- these bit-masks are special numbers used in the bit interleaving algorithm.
  -- see https://graphics.stanford.edu/~seander/bithacks.html#InterleaveBMN
  -- for the original algorithm and more details.
  x := (x | (x << 8)) &   16711935; -- 0x00FF00FF
  x := (x | (x << 4)) &  252645135; -- 0x0F0F0F0F
  x := (x | (x << 2)) &  858993459; -- 0x33333333
  x := (x | (x << 1)) & 1431655765; -- 0x55555555

  y := (y | (y << 8)) &   16711935; -- 0x00FF00FF
  y := (y | (y << 4)) &  252645135; -- 0x0F0F0F0F
  y := (y | (y << 2)) &  858993459; -- 0x33333333
  y := (y | (y << 1)) & 1431655765; -- 0x55555555

  RETURN (x << 1) | y;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
