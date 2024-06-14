#!/usr/bin/env bash
if ps aux | grep -v grep | grep "imposm" >/dev/null; then
  echo "imposm process is running."
  exit 0
else
  echo "imposm process is not running." 1>&2
  exit 1
fi
