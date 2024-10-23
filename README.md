# professional-examples

## check-url-latency

cURLs the target URL and returns a summary of key timings, like TCP Connect, SSL Connect, Time to First Byte, etc.

Has several different options available, which can be viewed with '-help'.

Originally created to verify latency of GCP Cloud Run services across different network paths (eg, Internet vs Cloud Interconnects), so includes authentication to successfully cURL GCP Cloud Run instances. 

The "Turbo cURL" mode  runs 10 concurrent cURLs 10 times; this is not intended to serve as a stress test, only to 'wake up' Cloud Run instances, as it was observed that regular HTTPS calls keep the service running and latency improves compared to a single, initial request. In general, there's probably a better way to do this.




## check-redirects

Loops through provided /24 network range and hits endpoints on HTTP and records any HTTP to HTTPS redirects. Originally used to determine if any public HTTP load balancer IPs were misconfigured and did not contain a 443 redirect. Boo, hiss, HTTP bad!




## check-fqdn

Check FQDN 40 times against default or provided DNS servers to get a feel for the scope/range of the results and how fast they are changing. This can be useful to know when thinking about using an FQDN address object for an FW rule (think AWS, GCP, Cloud).  If the the addresses are few and the hit count is low, then an FQDN object would be appropriate. If there are many results and the hit count is high, then an EDL list may be more appropriate. Slightly augmented original script (from a colleague) to allow for changing target nameserver.



## trend-chaser

Trying to accommodate... *interesting*... Executive asks. An unrelated team was given direction to scrape data from the target site, however, they quickly found themselves being rate-limited and blocked, thus NetEng was engaged. In the spirit of trying to assist, I put this tool together to (hopefully) identify an acceptable rate of requests to avoid being served 429s.