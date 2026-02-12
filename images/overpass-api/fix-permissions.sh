#!/bin/bash
# Fix socket and permission issues for Overpass API:
# 1. Remove stale sockets to prevent "Address already in use" errors
# 2. Symlink socket paths so Nginx and Dispatcher communicate on the same endpoint
# 3. Normalize ownership to overpass (1000:1000) to avoid root-lock issues
rm -f /db/db/osm3s_osm_base /dev/shm/osm3s_osm_base
ln -sf /db/db/osm3s_osm_base /dev/shm/osm3s_osm_base
chown -R 1000:1000 /db/db
