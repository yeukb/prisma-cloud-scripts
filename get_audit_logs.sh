#!/bin/bash

source ./config

credentials="{\"username\":\"$access_key\", \"password\":\"$secret_key\"}"
PRISMA_TOKEN=`curl -s -H "Content-Type: application/json" -d "$credentials" https://$prisma_api_endpoint/login | jq -r .token`

# For infomation on the time paramaeters, see https://prisma.pan.dev/api/cloud/api-time-range-model#relative-time
timeType=relative
timeAmount=1
timeUnit=day

curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "x-redlock-auth: $PRISMA_TOKEN" \
    "https://$prisma_api_endpoint/audit/redlock?timeType=$timeType&timeAmount=$timeAmount&timeUnit=$timeUnit" | jq .
