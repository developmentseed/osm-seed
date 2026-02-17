#!/bin/bash
# Fix permissions for Overpass API:
# 1. Remove stale sockets and shared memory files from previous runs
# 2. Normalize ownership to overpass (1000:1000) to avoid root-lock issues
# 3. Ensure /db and /db/db are traversable by nginx user for socket access
rm -f /dev/shm/osm3s_osm_base /dev/shm/osm3s_areas
find /db/db -name "osm3s*" -exec rm -f {} + 2>/dev/null || true
chown -R 1000:1000 /db/db
chmod o+x /db /db/db
