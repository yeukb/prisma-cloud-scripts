#!/bin/bash

source ./config

credentials="{\"username\":\"$access_key\", \"password\":\"$secret_key\"}"
PRISMA_TOKEN=`curl -s -H "Content-Type: application/json" -d "$credentials" https://$prisma_api_endpoint/login | jq -r .token`

curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "x-redlock-auth: $PRISMA_TOKEN" \
    "https://$prisma_api_endpoint/cloud/group/name?include_auto_created=true" | jq .
