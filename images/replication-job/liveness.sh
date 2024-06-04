#!/usr/bin/env bash
# This is a script for the complex evaluation of whether Osmosis or other processes are running in the container.
if [ $(ps -ef | grep -E 'java' | grep -v grep | wc -l) -ge 1 ]; then
  echo "Osmosis is running."
  exit 0
else
  echo "Osmosis is not running!" 1>&2
  exit 1
fi
