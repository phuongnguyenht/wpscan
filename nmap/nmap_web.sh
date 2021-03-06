#!/bin/bash

echo "Enter your website do you want to check"
read -p 'Your website example: targetWebsite.com or IP' website

echo "1. Web Application Firewall Detection"
echo "nmap -p80,443 --script http-waf-detect --script-args="http-waf-detect.aggro,http-waf-detect.detectBodyChanges" $website"
nmap -p80,443 --script http-waf-detect --script-args="http-waf-detect.aggro,http-waf-detect.detectBodyChanges" $website

echo "2. Web Application Firewall Fingerprint Detection"
echo "nmap -p80,443 --script http-waf-fingerprint $website"
nmap -p80,443 --script http-waf-fingerprint $website

echo "3. Find HTTP Errors"
echo "nmap -p80,443 --script http-errors $website"
nmap -p80,443 --script http-errors $website

echo "4. Find Shared & New Servers Require create file custom-subdomain-wordlist"
echo "nmap -p80,443 --script dns-brute --script-args dns-brute.threads=25,dns-brute.hostlist=/root/Desktop/custom-subdomain-wordlist.txt $website"
nmap -p80,443 --script dns-brute --script-args dns-brute.threads=25,dns-brute.hostlist=/root/Desktop/custom-subdomain-wordlist.txt $website

echo "5. Extract EXIF Data from Photos"
echo "nmap -p80,443 --script http-exif-spider $website"
nmap -p80,443 --script http-exif-spider $website

echo "6. Scan all port open with fast execution"
echo "nmap -sV -T4 -F  $website"
nmap -sV -T4 -F  $website

echo "7. Scan + OS and service detection with fast execution"
echo "nmap -A -T4 $website"
nmap -A -T4 $website

echo "8. Scanning for SQLi Vulns with Nmap"
echo "nmap -T4 -A -v --script sql-injection $website"
nmap -T4 -A -v --script sql-injection $website

echo "9. Heartbleed Scanner"
echo "nmap -sV --script=ssl-heartbleed $website"
nmap -sV --script=ssl-heartbleed $website