#!/bin/bash

# [REDACTED] is trying to scrape trends.google.com for data on specific keywords. 
# They've been asked to gather trend results for approx 5000 different terms. They want
# weekly trends for each term going back five years. That's [REDACTED] for you, always
# chasing trends.
# 
# To scrape this data, they are using PyTrends. PyTrends' documentation indicates that Google
# will begin to serve 429s if you exceed 1400 requests within 4 hours. 
# 
# This script will send 1500 requests to the term specified. I've been changing
# the sleep amount to try for different time frames instead of scripting different windows.
# ~11s for less than 1400 over 4 hours
# No sleep stops at 91 reqs in around 20 seconds.


read -p "Enter term you would like to search for: " term

# Google will serve a 429 if you don't include a 'real' cookie with the request.
# cURL captures the cookie and it is stored in a file to be parsed.

curl -L --cookie-jar - 'https://trends.google.com' -s -o /dev/null > trendy.cookie

# Parses the appropriate NAME and VALUE columns from the stored cookie.

cookie_name=$(cat trendy.cookie | grep google.com | awk '{print $6}')
cookie_val=$(cat trendy.cookie | grep google.com | awk '{print $7}')

# Capture time to later determine X requests were sent over Y timeframe.
rstart=`date +%s`

# Loop cURL 1500 times. Track each repetition to determine how many loops were successful. 
	for i in {1..1500} ; do
	curl -L 'https://trends.google.com/trends/explore?q='$term'' -H 'Cookie: '$cookie_name'='$cookie_val'' -w %{http_code} -so /dev/null > http.result
	http_status=$( cat http.result )
	reps=$((reps + 1))
	echo $reps

# That sleep value I mentioned earlier.
	sleep 11

# If we get anything other than a 200, stop the loop. 
# Print non-200 HTTP status and the rep it was served on.
# Print how many requests were sent over how many seconds.

		if [ $http_status != 200 ] ; then
		rstop=`date +%s`
		rtime=$((rstop-rstart))
		echo "WARNING!"
		echo "RESULT IS $http_status ON REP $reps"
		echo ""
		echo "$reps REQUESTS OVER $rtime SECONDS"
		break
	fi
	

done