#!/bin/bash

read -p "Enter first three octets of /24 IP range (eg, '136.36.118'): " iprange

# Loops through /24 range
for i in $iprange.{1..254} ; do
	# Print IP to terminal and 'redirect-results.txt'
	echo "CHECKING $i..." | tee -a redirect-results.txt
	# cURL IP, append HTTP code and redirect URL if applicable to 'redirect-results.txt'
	curl -w "%{http_code} %{redirect_url}" -m 5 -s -o /dev/null $i:80 >> redirect-results.txt
	# Echo new line to 'redirect-results.txt'
	echo "" >> redirect-results.txt
done