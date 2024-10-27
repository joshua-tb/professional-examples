#!/bin/bash

#### "Boolean" variables to be checked whether OPTIONS were given -- or not.
#### If the user specifies an option (or is ASKED for them) these will be set to TRUE.

optcloudrun=
detailed=
protocol=HTTPS
debugmode=false
turbomode=false
tshootmode=false

#### Asks for user input

ask_cloudrun () {

echo ""
echo "Are you testing a Cloud Run service? (yes/no)"
echo ""
read input
if [[ $input == "yes" || $input == "Yes" || $input == "y" || $input == "Y" ]]; then
		optcloudrun=true
fi

}

ask_url () {

read -p "Enter URL: ${protocol}://" url

}

#### Begins authentication sequence.


checkauth () {

echo ""
historic_auth=$(gcloud auth list 2>&1 | grep -i "no credentialed accounts")
if [[ $historic_auth != "" ]]; then
	echo ""
    echo "After completing authentication, please paste your authorization code into the terminal and press Enter."
    echo ""
	auth
else
	echo ""
	echo "I can, like, totally tell this isn't your first time."
	checktoken
fi
}

checktoken () {

token=$(gcloud auth print-identity-token 2>&1)  #>& /dev/null 
if [[ "$(echo "$token" | grep "Reauthentication required.")" == "Reauthentication required." ]]; then
	echo ""
	echo "After completing authentication, please paste your authorization code into the terminal and press Enter."
    echo ""	
	auth
else
	echo ""
    echo "And you've done it recently? Good for you."
fi
}

auth ()  { 

echo "$(gcloud auth login | grep https)"; 
}


#### Executes cURL for Cloud Run instances. MUST pass identity token via header AND
#### be authenticated. 

cloudrun () {
echo ""
completeresults=$(curl -L -s \
-H "Authorization: Bearer $(gcloud auth print-identity-token)" \
-w "
tcp.connect: %{time_connect}
time.firstbyte: %{time_starttransfer}
time.total: %{time_total}
app.connect: %{time_appconnect}
local.ip: %{local_ip}
remote.ip: %{remote_ip}
http.code: %{http_code}
dl.size: %{size_download}
dl.speed: %{speed_download}
num.redirects: %{num_redirects}
time.dns: %{time_namelookup}
time.prefirstbyte: %{time_pretransfer}
final.url: %{url_effective}
num.connects: %{num_connects}
ssl.verify: %{ssl_verify_result}
" \
--url ${protocol}://${url})

echo "$completeresults" > tmpresults.txt

}

#### Create data index from cURL results

createindex () {
tcpconnect=$(echo $(cat tmpresults.txt | grep tcp.connect | awk '{print $2}')*1000 | bc)
appconnect=$(echo $(cat tmpresults.txt | grep app.connect | awk '{print $2}')*1000 | bc)
timefirstbyte=$(echo $(cat tmpresults.txt | grep time.firstbyte | awk '{print $2}')*1000 | bc)
total=$(echo $(cat tmpresults.txt | grep time.total | awk '{print $2}')*1000 | bc)
localip=$(cat tmpresults.txt | grep local.ip | awk '{print $2}')
remoteip=$(cat tmpresults.txt | grep remote.ip | awk '{print $2}')
finalurl=$(cat tmpresults.txt | grep final.url | awk '{print $2}')
httpcode=$(cat tmpresults.txt | grep http.code | awk '{print $2}')

timedns=$(echo $(cat tmpresults.txt | grep time.dns | awk '{print $2}')*1000 | bc)
dlsize=$(echo $(cat tmpresults.txt | grep dl.size | awk '{print $2}')/1000 | bc)
dlspeed=$(echo $(cat tmpresults.txt | grep dl.speed | awk '{print $2}')/1000 | bc)
numredirects=$(cat tmpresults.txt | grep num.redirects | awk '{print $2}')
timeprefirstbyte=$(echo $(cat tmpresults.txt | grep time.prefirstbyte | awk  '{print $2}')*1000 | bc)
errormessage=$(cat tmpresults.txt | grep error.message | awk  '{print $2}')
exitcode=$(cat tmpresults.txt | grep exit.code | awk  '{print $2}') 
httpversion=$(cat tmpresults.txt | grep http.version | awk  '{print $2}')
numconnects=$(cat tmpresults.txt | grep num.connects | awk  '{print $2}')
sslverify=$(cat tmpresults.txt | grep ssl.verify | awk  '{print $2}')
postsslfirstbyte=$(echo $timefirstbyte-$appconnect | bc)
}


########## TURBO MODE ##########


turbomode () {



turbocloudrun () {

turbocurl () {
	
	for i in {1..10}
	do
	echo "$(curl -Ls -H "Authorization: Bearer ${cachedtoken}" \
	-w "tcp.connect: %{time_connect} \
	app.connect: %{time_appconnect} \
	time.firstbyte: %{time_starttransfer} \
	time.total: %{time_total} \
	http.code: %{http_code} \
	final.url: %{url_effective}" \
	-o /dev/null \
	--url ${protocol}://${url})" 
	done
	
	}
	
for i in {1..1}
do
	turbocurl > turbo.txt & 
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt & 
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	wait
done	

}

turbo () {

turbocurl () {
	
	for i in {1..10}
	do
	echo "$(curl -Ls \
	-w "tcp.connect: %{time_connect} \
	app.connect: %{time_appconnect} \
	time.firstbyte: %{time_starttransfer} \
	time.total: %{time_total} \
	http.code: %{http_code} \
	final.url: %{url_effective}" \
	-o /dev/null \
	--url ${protocol}://${url})" 
	done
	
	}
	
for i in {1..1}
do
	turbocurl > turbo.txt & 
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt & 
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	wait
done	

}

turbotally () {
echo "#########################################"
echo ""
echo "$protocol Response Times for $url"
echo ""
echo "Turbo Mode Activated!! 10 Successive Requests from 10 Concurrent 'Users'"
echo "-----------------------------------------"
echo ""
echo "Average Total Time to Complete:"
echo ""$( echo "scale=2; $(awk '{sum+=$8;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "Average Time for TCP Connect:"
echo ""$( echo "scale=3; $(awk '{sum+=$2;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "Average Time for SSL Connect:"
echo ""$( echo "scale=2; $(awk '{sum+=$4;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "Average Time to First Byte:"
echo ""$( echo "scale=2; $(awk '{sum+=$6;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "#########################################"

echo ""
}

cachetoken () {
cachedtoken=$(gcloud auth print-identity-token)

}





if [ -z "$url" ]; then
	ask_url
fi

if [[ "$optcloudrun" == "true" ]]; then
	checkauth
	echo ""
	echo "Getting swole..."
	echo ""
	cachetoken
	turbocloudrun
else
	echo ""
	echo "Getting swole..."
	echo ""
	turbo
fi

turbotally

if [[ "$debugmode" == "false" ]]; then
	rm turbo.txt
fi
	
}

########## END TURBO MODE ##########


######### TURBO TROUBLESHOOTING ###########
turbotshoot () {

startturbo () {

turbocurl () {
	
	for i in {1..10}
	do
	echo "$(curl -Ls \
	-w "tcp.connect: %{time_connect} \
	app.connect: %{time_appconnect} \
	time.firstbyte: %{time_starttransfer} \
	time.total: %{time_total} \
	http.code: %{http_code} \
	final.url: %{url_effective}" \
	-o /dev/null \" 
	done
}


	
for i in {1..1}
do
	turbocurl > turbo.txt & 
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt & 
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	turbocurl >> turbo.txt &
	wait
done	

}


turbotally () {
echo "#########################################"
echo ""
echo "$protocol Response Times for $url"
echo ""
echo "Turbo Mode Activated!! 10 Successive Requests from 10 Concurrent 'Users'"
echo "-----------------------------------------"
echo ""
echo "Average Total Time to Complete:"
echo ""$( echo "scale=2; $(awk '{sum+=$8;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "Average Time for TCP Connect:"
echo ""$( echo "scale=3; $(awk '{sum+=$2;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "Average Time for SSL Connect:"
echo ""$( echo "scale=2; $(awk '{sum+=$4;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "Average Time to First Byte:"
echo ""$( echo "scale=2; $(awk '{sum+=$6;}END{print sum}' turbo.txt)/100*1000" | bc )"ms"
echo ""
echo "#########################################"

echo ""
}

cachetoken () {
cachedtoken=$(gcloud auth print-identity-token)

}


cachetoken

startturbo

turbotally

if [[ "$debugmode" == "false" ]]; then
	rm turbo.txt
fi
	
}





#### Displays usage information.

help () {
echo ""
echo "This tool will connect to the chosen URL and report various timing-related statistics."
echo "By default, the tool is configured to use HTTPS."
echo ""
echo "Basic options:"
echo ""
echo "	-u target-url 		Defines target URL. Do NOT prefix with 'https:// | http://'"
echo "	-r 			Use when targeting a Cloud Run service to properly authenticate."
echo "	-i			Use HTTP instead of HTTPS -- INSECURE"
echo "	-d 			Saves debug output - keeps all cURL information stored in 'tmpresults.txt'"
echo "				for review. When used with Turbo mode, output will be written to"
echo "				'turbo.txt' -- but why are you debugging with Turbo Mode?"
echo "	-v 			Verbose results"
echo "	-t 			Turbo Mode -- Starts 10 concurrent cURLs that each run 10 times. Not"
echo "				compatible with -v. Test before Turbo! Make sure a single cURL works"
echo "				before going to the guns show! Not to be used as a stress test and only"
echo "				prints an average of all values."
echo ""

}

#### Executes cURL for NOT Cloud Run. Does NOT require authentication.

notcloudrun () {
echo ""
completeresults=$(curl -L -s \
-w "
tcp.connect: %{time_connect}
time.firstbyte: %{time_starttransfer}
time.total: %{time_total}
app.connect: %{time_appconnect}
local.ip: %{local_ip}
remote.ip: %{remote_ip}
http.code: %{http_code}
dl.size: %{size_download}
dl.speed: %{speed_download}
num.redirects: %{num_redirects}
time.dns: %{time_namelookup}
time.prefirstbyte: %{time_pretransfer}
final.url: %{url_effective}
num.connects: %{num_connects}
ssl.verify: %{ssl_verify_result}
" \
--url ${protocol}://${url})

echo "$completeresults" > tmpresults.txt

}

### TROUBLESHOOTING MODE -- INSERT WHATEVER YOU NEED ###

tshooter () {
echo ""
completeresults=$(curl -s -w "
tcp.connect: %{time_connect}
time.firstbyte: %{time_starttransfer}
time.total: %{time_total}
app.connect: %{time_appconnect}
local.ip: %{local_ip}
remote.ip: %{remote_ip}
http.code: %{http_code}
dl.size: %{size_download}
dl.speed: %{speed_download}
num.redirects: %{num_redirects}
time.dns: %{time_namelookup}
time.prefirstbyte: %{time_pretransfer}
final.url: %{url_effective}
num.connects: %{num_connects}
ssl.verify: %{ssl_verify_result}
" \
  -o /dev/null)

echo "$completeresults" > tmpresults.txt

}

#### Displays basic results

printbasicresults () {
echo "#########################################"
echo ""
echo "${protocol} Response Times for $url"
echo "-----------------------------------------"
echo ""

echo "$localip ---> $remoteip : $finalurl"
echo ""

echo "HTTP Code:"
echo "$httpcode"
echo ""

echo "Time for TCP Connect:"
echo ${tcpconnect}ms
echo ""

echo "Time for SSL Connect:"
echo ${appconnect}ms
echo ""

echo "Time to First Byte (from SSL Connect):"
echo ${postsslfirstbyte}ms
echo ""

echo "Total Time to First Byte:"
echo ${timefirstbyte}ms
echo ""

echo "Total Time to Complete:"
echo ${total}ms
echo ""
echo "#########################################"

echo ""

}


#### Displays verbose results

printverboseresults () {
echo "#########################################"
echo ""
echo "$protocol Response Times for $url -- VERBOSE"
echo "-----------------------------------------"
echo ""

echo "$localip ---> $remoteip : $finalurl"
echo ""

echo "HTTP Code:"
echo "$httpcode"
echo ""

echo "SSL Verification (0 indicates success):"
echo "$sslverify"
echo ""

echo "Number of Connections:"
echo "$numconnects"
echo ""

echo "Number of Redirects:"
echo "$numredirects"
echo ""

echo "Time for DNS Lookup:"
echo ${timedns}ms
echo ""

echo "Time for TCP Connect:"
echo ${tcpconnect}ms
echo ""

echo "Time for SSL Connect:"
echo ${appconnect}ms
echo ""

echo "Time for Pre- First Byte:"
echo ${timeprefirstbyte}ms
echo ""

echo "Time to First Byte (from SSL Connect):"
echo ${postsslfirstbyte}ms
echo ""

echo "Total Time to First Byte:"
echo ${timefirstbyte}ms
echo ""

echo "Total Time to Complete:"
echo ${total}ms
echo ""

echo "Total Download Size:"
echo ${dlsize}KB
echo ""

echo "Download Speed:"
echo ${dlspeed} KB/s
echo ""

echo "#########################################"

echo ""

}


#### Processes input OPTIONS 

while getopts "hu:rnivdbBt" option; do
	case $option in
		h) 	#help
			help
			exit;;
		u) # URL
			url="$OPTARG";;
		r) # IS Cloud Run
			optcloudrun=true;;
		n) # IS NOT Cloud Run
			optcloudrun=false;;
		i) # IS INSECURE / HTTP
			protocol=HTTP;;
		v) # Verbose output
			detailed=true;;
		d) #Debug mode -- NO CLEANUP
			debugmode=true;;
		b) #Specific troubleshooting flag
			tshootmode=true;;
		B) #Turbo Troubleshooting flag
			turbotshoot
			exit;;
		t) # Turbo Mode
			turbomode
			exit;;
	esac
done

#### Examine variables and EXECUTE

if [[ "$tshootmode" == "false" ]] && [ -z "$url" ]; then
	ask_url
fi

#if [ -z "$optcloudrun" ]; then
#	ask_cloudrun
#fi

if [[ "$tshootmode" == "true" ]]; then
	tshooter
elif [[ "$optcloudrun" == "true" ]]; then
	checkauth
	cloudrun
else
	notcloudrun
fi


createindex

if [[ "$detailed" == "true" ]]; then
	printverboseresults
else
	printbasicresults
fi

#### Cleanup... or not

if [[ "$debugmode" == "false" ]]; then
	rm tmpresults.txt
fi