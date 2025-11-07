#!/bin/bash
set -eou pipefail

sha256=$1

curl --request GET \
	--url https://www.virustotal.com/api/v3/files/${sha256} \
	--header 'accept: application/json' \
	--header 'x-apikey: API_KEY_GOES_HERE'

