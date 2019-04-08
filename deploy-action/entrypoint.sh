#!/bin/bash

: ${CF_USERNAME:?"Missing env-var $CF_USERNAME"}
: ${CF_PASSWORD:?"Missing env-var $CF_PASSWORD"}
: ${CF_SPACE:?"Missing env-var $CF_SPACE"}
: ${CF_API:?"Missing env-var $CF_API"}
: ${CF_ORG:?"Missing env-var $CF_ORG"}
: ${CF_APP:?"Missing env-var $CF_APP"}

make

cf login -a $CF_API -u $CF_USERNAME -p $CF_PASSWORD
cf target -o $CF_ORG -s $CF_SPACE
cf push $CF_APP
