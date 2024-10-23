#!/bin/bash
# Check FQDN 40 times against google external DNS servers to get a feel for the scope/range of the results and how fast they are changing.
# This can be useful to know when thinking about using an FQDN address object for an FW rule (think AWS, GCP, Cloud).  If the the addresses are few and the hit count is low, then an FQDN object would be appropriate.
# If there are many results and the hit count is high, then an EDL list may be more appropriate.
# Slightly augmented original script (from a colleague) to allow for changing target nameserver

# Prompt for FQDN
read -p "Enter FQDN: " fqdn
echo ""
read -p "nameserver (leave blank for host default): " nameserver

# Time start
rstart=`date +%s`

# For loop input
results=$(for i in {1..40}; do nslookup $fqdn $nameserver | grep Address | tail -n 5; done)

# Time stop
rstop=`date +%s`
rtime=$((rstop-rstart))

# Display results
echo "Domain: " $fqdn
echo "Lookups: 40x: In "$rtime" Seconds"
echo ""
echo "Hits Addresses"
echo "${results//"Address: "}" | sort -nr | uniq -c