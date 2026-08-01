#!/bin/bash
set -eou pipefail

UPSTREAM_OWNER=oliver006
UPSTREAM_REPO=redis_exporter

curl -s https://api.github.com/repos/"$UPSTREAM_OWNER"/"$UPSTREAM_REPO"/releases/latest \
     | jq -r ".tag_name"
