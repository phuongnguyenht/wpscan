#! /bin/bash
#
# * @description: Check Hardening Server Linux
# * @author  nolove
# * @version 1.0

cat /etc/pam.d/system-auth | grep password | grep pam_pwquality.so 
cat /etc/login.defs | grep PASS_MAX_DAYS 
cat /etc/ssh/sshd_config | grep ClientAliveInterval 
cat /etc/ssh/sshd_config | grep ClientAliveCountMax 
cat /etc/ssh/sshd_config | grep PermitEmptyPasswords  
cat /etc/ssh/sshd_config | grep MaxAuthTries   

cat /etc/snmp/snmpd.conf | grep lvbsnmpkey
cat /etc/ntp.conf | grep server | grep "10.36.32.13"
cat /etc/rsyslog.conf | grep 514

cat /etc/passwd | grep /bin/bash

##usermod -s /sbin/nologin testuser