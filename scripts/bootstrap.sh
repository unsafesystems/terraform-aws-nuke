#!/bin/sh
set -euo pipefail

# Handler format: <script_name>.<bash_function_name>
#
# The script file <script_name>.sh  must be located at the root of your
# function's deployment package, alongside this bootstrap executable.
source $(dirname "$0")/"$(echo $_HANDLER | cut -d. -f1)"

# Prepares the config file for aws-nuke
prepare

while true
do
    # Request the next event from the Lambda runtime
    HEADERS="$(mktemp)"
    EVENT_DATA=$(curl -v -sS -LD "$HEADERS" -X GET "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")
    INVOCATION_ID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)

    # Execute the handler function from the script
    RESPONSE=$($(echo "$_HANDLER" | cut -d. -f2) "$EVENT_DATA")

    # Send the response to Lambda runtime
    curl -v -sS -X POST "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$INVOCATION_ID/response" -d "$RESPONSE"
done
