#!/bin/bash

set -e

client_id=$1
key_file=$2
birth_number=$3
login_uri=${4:-https://externaltest-login.frende.no/identityserver}

if [[ -z $client_id  ]] || [[ -z $key_file ]] || [[ -z $birth_number ]]; then
	echo "Usage: ./get_access_token.sh <your client id> <key file location> <birth number> [login url}"
	exit 1
fi

if [[ ! -f $key_file ]]; then
	echo "Could not open key at ${key_file}. Is it a valid rsa key?"
	exit 1
fi

header="{
	\"alg\": \"RS256\",
	\"typ\": \"JWT\"
}"

body="{
	\"iss\": \"${client_id}\",
	\"sub\": \"${client_id}\",
	\"aud\": \"${login_uri}/connect/token\",
	\"jti\": \"$(date +%s)\",
	\"exp\": $(date -d "+8 hours" +%s)
}"

base64_encode()
{
	declare input=${1:-$(</dev/stdin)}
	printf '%s' "${input}" | openssl enc -base64 -A | tr '+/' '-_' | tr -d '=';
}
rs256_sign()
{
	declare input=${1:-$(</dev/stdin)}
	printf '%s' "${input}" | openssl dgst -binary -sha256 -sign "${key_file}"
}

header_base64=$(echo "${header}" | base64_encode )
body_base64=$(echo "${body}" | base64_encode )

header_body=$(echo "${header_base64}.${body_base64}")
signature=$(echo "${header_body}" | rs256_sign | base64_encode )

assertion="${header_body}.${signature}"

curl --request POST \
	--url "${login_uri}/connect/token" \
	--header 'content-type: application/x-www-form-urlencoded' \
	--data "client_id=${client_id}&grant_type=affiliation&scope=agreement&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=${assertion}&customer_birth_number=${birth_number}"
