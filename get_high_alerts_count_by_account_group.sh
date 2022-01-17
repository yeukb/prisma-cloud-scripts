#!/bin/bash

# Define parameters
source ./config
POLICY_SEVERITY=high
ALERT_STATUS=open

# The filename for the csv file
outputfile=num_high_alerts_by_account_group_2.csv

# Get Prisma Cloud token
credentials="{\"username\":\"$access_key\", \"password\":\"$secret_key\"}"
PRISMA_TOKEN=`curl -s -H "Content-Type: application/json" -d "$credentials" https://$prisma_api_endpoint/login | jq -r .token`

# Note the approximate time the token was issued
token_start_time=`date +%s`

# Get the list of account groups
ACCOUNT_GROUPS_RAW=$(curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "x-redlock-auth: $PRISMA_TOKEN" \
    "https://$prisma_api_endpoint/cloud/group/name?include_auto_created=true" | jq -r '.[].name')

# Polulate the list of account groups into the array ACCOUNT_GROUPS
IFS=$'\n' read -r -d '' -a ACCOUNT_GROUPS <<< "$ACCOUNT_GROUPS_RAW"

echo "Account Group,# of High Alerts" > $outputfile

# Go through the list of Account Groups and get the number of high alerts for each Account Group
for i in "${ACCOUNT_GROUPS[@]}"
do
  # check whether the token is more than 9 minutes old. If yes, refresh the token.
  # NOTE: Tokens are valid for 10 mins, so need to refresh the token before it expires
  token_now=`date +%s`
  token_elapsed=$((token_now - token_start_time))
  if [ $token_elapsed -gt 540 ]
  then
    PRISMA_TOKEN=`curl -s -H "Content-Type: application/json" -H "x-redlock-auth: $PRISMA_TOKEN" https://$prisma_api_endpoint/auth_token/extend | jq -r .token`
    token_start_time=`date +%s`
    # echo "Token Refreshed at $token_start_time"
  fi

  # Get the number of alerts by policy, and then sum all to get the total number of high alerts for an Account Group
  numAlerts=$(curl -s -X POST \
    -H "Content-Type: application/json;charset=UTF-8" \
    -H "Accept: application/json;charset=UTF-8" \
    -H "x-redlock-auth: $PRISMA_TOKEN" \
    -d "{\"detailed\":false,\"filters\":[{\"name\":\"timeRange.type\",\"operator\":\"=\",\"value\":\"ALERT_OPENED\"},{\"name\":\"alert.status\",\"operator\":\"=\",\"value\":\"$ALERT_STATUS\"},{\"name\":\"policy.severity\",\"operator\":\"=\",\"value\":\"$POLICY_SEVERITY\"},{\"name\":\"account.group\",\"operator\":\"=\",\"value\":\"$i\"}],\"timeRange\":{\"type\":\"to_now\",\"value\":\"epoch\"}}" \
    "https://$prisma_api_endpoint/alert/policy" | jq '[.[].alertCount] | add // empty')


  # if you want to see the output while the command is running, uncomment the line with the "tee" command
  #     and comment the line with the ">>" operator
  # if you do not want to see the output while the command is running, uncomment the line wth the ">>" operator
  #     and comment the line with the "tee" command
  if [[ -z $numAlerts ]]
  then
    # echo "$i,0" >> $outputfile
    echo "$i,0" | tee -a $outputfile
  else
    # echo "$i,$numAlerts" >> $outputfile
    echo "$i,$numAlerts" | tee -a $outputfile
  fi
done
