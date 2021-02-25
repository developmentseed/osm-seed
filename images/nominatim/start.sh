#!/bin/bash

# This script will be in charge to:
# - Execute the data import into Database
# - Starting the Database service
# - Keep updated the database with replication files

echo 'Start init......'
sh /app/init.sh
echo 'Start database and update......'
sh /app/startpostgres.sh & sh /app/update.sh
