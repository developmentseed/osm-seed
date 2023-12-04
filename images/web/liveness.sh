#!/usr/bin/env bash
# This is a script for the complex evaluation of whether Apache or other processes are running in the container.
if [ $(ps -ef | grep -E 'httpd|apache2' | grep -v grep | wc -l) -ge 1 ]; then
  echo "Apache is running."
  exit 0
else
  echo "Apache is not running!" 1>&2
  exit 1
fi
