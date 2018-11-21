/*
	Adds indexes to OSM table columns to increase query performance per the tegola configuration.
*/

BEGIN;
	CREATE INDEX ON osm_transport_lines_gen0 (type);
	CREATE INDEX ON osm_transport_lines_gen1 (type);
	CREATE INDEX ON osm_transport_lines (type);
	CREATE INDEX ON osm_admin_areas (admin_level);
	CREATE INDEX ON osm_landuse_areas_gen0 (type);
	CREATE INDEX ON osm_water_lines (type);
	CREATE INDEX ON osm_water_lines_gen0 (type);
	CREATE INDEX ON osm_water_lines_gen1 (type);
	CREATE INDEX ON osm_water_areas (type);
	CREATE INDEX ON osm_water_areas_gen0 (type);	
	CREATE INDEX ON osm_water_areas_gen1 (type);
COMMIT;
