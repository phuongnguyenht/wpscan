#!/bin/bash
echo "Use the Basic Syntax Nikto scan website"

echo "Enter your website do you want to check"
read -p 'Your website example: targetWebsite.com or IP: ' website 
read -p 'Your website is http or https:  ' ssl 
if [ $ssl = "HTTP" ] || [ $ssl = "http" ] ; then
	echo "nikto -h $website"
	nikto -h $website

elif [ $ssl = "HTTPS" ] || [ $ssl = "https" ] ; then
	echo "nikto -h $website -ssl"
	nikto -h $website -ssl

else
	echo "You don't enter your http or https to input"
fi 
