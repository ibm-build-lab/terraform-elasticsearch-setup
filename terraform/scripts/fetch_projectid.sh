#!/bin/bash

PROJECT_NAME=$1
TOKEN=$2
REGION=$3
API_RESPONSE=$(curl -s 'https://api.${REGION}.codeengine.cloud.ibm.com/v2/projects'\
  -H "Authorization: ${TOKEN}"  | jq '.')
PROJECT_ID=$(echo $API_RESPONSE | jq -r --arg PROJECT_NAME "$PROJECT_NAME" '.projects[] | select(.name==$PROJECT_NAME) | .id')

if [ -z "$PROJECT_ID" ]; then
  echo "{\"project_id\": \"\", \"exists\": \"false\"}"
else
  echo "{\"project_id\": \"$PROJECT_ID\", \"exists\": \"true\"}"
fi
