#!/bin/bash
echo Hello Boss, Enter your website do you want to scan username Login

while true; do
	echo "Do you want to continue scan username? Y: Continue, N: Quit"
	read -p 'Y or N: ' result
	if [ $result = "N" ] || [ $result = "n" ] ; then
		echo You chose no, good bye 
		exit

	elif [ $result = "Y" ] || [ $result = "y" ] ; then
		read -p 'Website link: ' website
		expect user.sh "$website"

	elif  [ ! $result = "Y" ] || [ ! $result = "y" ] || [ ! $result = "N" ] || [ ! $result = "n" ] || [ -z "$result" ] ; then
		echo "please Enter Y: Continue, N: Quit"
	fi 
done
