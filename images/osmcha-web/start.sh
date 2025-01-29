#!/usr/bin/env bash
set -x
export BUILD_ENV=prod
export REACT_APP_PRODUCTION_API_URL=/api/v1
yarn build
