#!/bin/bash

# Requires jq to be installed on the system you are running the script: https://stedolan.github.io/jq/download/ 

# Instructions to install jq:
# Ubuntu:
# sudo apt-get install jq 
# MacOS: 
# brew install jq
# RHEL
# yum install jq


# Recommendations for hardening are: store variables in a secret manager of choice or export the access_keys/secret_key as env variables in a separate script. 

# Access key should be created in the Prisma Cloud Enterprise Edition Console under: Settings > Accesskeys
# Example of a better way: pcee_console_api_url=$(vault kv get -format=json <secret/path> | jq -r '.<resources>')

# Before running the script, EXPORT the below variables in your terminal/shell.
# Replace the "<CONSOLE_API_URL>" by mapping the API URL found on https://prisma.pan.dev/api/cloud/api-url
# Replace the "<ACCESS_KEY>", "<SECRET_KEY>" marks respectively below.

##########################
### SCRIPT BEGINS HERE ###
##########################

pcee_console_api_url=<CONSOLE_API_URL> # example: https://api2.prismacloud.io
pcee_accesskey=<ACCESS_KEY>
pcee_secretkey=<SECRET_KEY>

# for alert dismissal 


dismiss_note="dismissal note here" # your custom note to dismiss
alert_id="2378dbf4-b104-4bda-9b05-7417affbba3f" # alert ID 
policy_name="AWS Default Security Group does not restrict all traffic" # policy name
time_unit="year" # minute, hour, day, week, month, year
time_unit_amount="1" # integer value





##### NO EDITS BELOW THIS NEEDED #######

pcee_auth_body_single="
{
 'username':'${pcee_accesskey}',
 'password':'${pcee_secretkey}'
}"

pcee_auth_body="${pcee_auth_body_single//\'/\"}"


pcee_auth_token=$(curl -s --request POST \
                       --url "${pcee_console_api_url}/login" \
                       --header 'Accept: application/json; charset=UTF-8' \
                       --header 'Content-Type: application/json; charset=UTF-8' \
                       --data "${pcee_auth_body}" | jq -r '.token')



alert_payload="{\"alerts\":[],\"dismissalNote\":\"${dismiss_note}\",\"filter\":{\"filters\":[{\"name\":\"timeRange.type\",\"operator\":\"=\",\"value\":\"ALERT_OPENED\"},{\"name\":\"alert.status\",\"operator\":\"=\",\"value\":\"open\"},{\"name\":\"policy.name\",\"operator\":\"=\",\"value\":\"${policy_name}\"}],\"timeRange\":{\"type\":\"relative\",\"value\":{\"amount\":\"${time_unit_amount}\",\"unit\":\"${time_unit}\"}}},\"policies\":[\"${alert_id}\"]}"



curl "${pcee_console_api_url}/alert/dismiss" \
  -H 'Accept: application/json, text/plain, */*' \
  -H "x-redlock-auth: ${pcee_auth_token}" \
  -H 'Content-Type: application/json' \
  --data-raw "${alert_payload}" \
  --compressed
