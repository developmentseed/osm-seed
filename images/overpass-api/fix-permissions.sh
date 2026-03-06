#!/bin/bash
# Fix permissions for Overpass API:
# 1. Remove stale sockets and shared memory files from previous runs
# 2. Normalize ownership to overpass (1000:1000) to avoid root-lock issues
# 3. Ensure /db and /db/db are traversable by nginx user for socket access
rm -f /dev/shm/osm3s_osm_base /dev/shm/osm3s_areas
find /db/db -name "osm3s*" -exec rm -f {} + 2>/dev/null || true
chown -R 1000:1000 /db/db
chmod o+x /db /db/db
set -e

echo "Starting socket cleanup..."

# 1. Clean up sockets in ALL possible paths
rm -f /db/db/osm3s_osm_base
rm -f /dev/shm/osm3s_osm_base
rm -f /osm3s_osm_base

# 2. Clean up any orphaned sockets in /dev/shm and root
find /dev/shm -type s -name "osm3s*" -delete 2>/dev/null || true
find / -maxdepth 1 -type s -name "osm3s*" -delete 2>/dev/null || true

# 3. Ensure /dev/shm is writable
chmod 1777 /dev/shm

# 4. CRITICAL: The /db directory must allow access from other users
# nginx needs to be able to enter /db to reach /db/db/
chmod 755 /db 2>/dev/null || true
chmod 755 /db/db 2>/dev/null || true

# 5. Ensure correct permissions on the database directory
chown -R 1000:1000 /db/db 2>/dev/null || true

echo "Socket cleanup completed successfully"
