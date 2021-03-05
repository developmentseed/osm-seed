#!/bin/bash

echo 'Starting init...'
sh /app/init.sh
echo 'Starting database and updates...'
sh /app/startpostgres.sh & sh /app/update.sh
