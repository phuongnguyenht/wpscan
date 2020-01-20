#! /bin/bash
#
# * @description: Check Hardening Server Linux
# * @author  nolove
# * @version 1.0

cssh="/etc/ssh/sshd_config"
cntp="/etc/ntp.conf"
csnmp="/etc/snmp/snmpd.conf"
crsyslog="/etc/rsyslog.conf"
clogin="/etc/login.defs"
cpam="/etc/pam.d/system-auth"

# check current user
cUser=`whoami`
echo "Current user is: " $cUser
if [[ $cUser == "root" ]]
then
	echo "Begin running and check hardening"
	
	# Check SSH PermitRootLogin no
	echo "check SSH PermitRootLogin no"
	cat ${cssh} | grep PermitRootLogin | grep "^[^#;]" | grep yes 
	[ $? -eq 0 ] && sudo sed -i 's/PermitRootLogin yes/# PermitRootLogin yes/g' ${cssh} || echo "Comment PermitRootLogin yes done"
	cat ${cssh} | grep PermitRootLogin | grep "^[^#;]" | grep no
	if [ $? -eq 0 ]; then
		echo "Cau hinh PermitRootLogin no done" 
	else
		echo "Config PermitRootLogin no " 
		echo "PermitRootLogin no" >> ${cssh}
	fi
	
	# Check SSH Cau hinh MaxAuthTries = 6
	echo "Check SSH Cau hinh MaxAuthTries = 6"
	cat ${cssh} | grep MaxAuthTries | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Cau hinh MaxAuthTries done" 
	else
		echo "Config MaxAuthTries = 6" 
		echo "MaxAuthTries = 6" >> ${cssh}
	fi	
	
	# Gioi han thoi gian khi nguoi dung khong tuong tac voi server ClientAliveInterval 300   ClientAliveCountMax 0
	echo "Cau hinh Gioi han thoi gian khi nguoi dung khong tuong tac voi server"
	cat ${cssh} | grep ClientAliveInterval | grep "^[^#;]" | grep 300
	if [ $? -eq 0 ]; then
		echo "Cau hinh ClientAliveInterval 300 done" 
	else
		echo "Config ClientAliveInterval 300" 
		sed -i 's/ClientAliveInterval/# ClientAliveInterval/g' ${cssh}
		echo "ClientAliveInterval 300" >> ${cssh}
	fi	
	cat ${cssh} | grep ClientAliveCountMax | grep "^[^#;]" | grep 0
	if [ $? -eq 0 ]; then
		echo "Cau hinh ClientAliveCountMax 0 done" 
	else
		echo "Config ClientAliveCountMax 0" 
		sed -i 's/ClientAliveCountMax/# ClientAliveInterval/g' ${cssh}
		echo "ClientAliveCountMax 0" >> ${cssh}
	fi
	
	# Khong cho user co password rong dang nhap PermitEmptyPasswords no
	echo "Khong cho user co password rong dang nhap"
	cat ${cssh} | grep PermitEmptyPasswords | grep "^[^#;]" | grep yes
	sed -i 's/PermitEmptyPasswords/# PermitEmptyPasswords/g' ${cssh}
	cat ${cssh} | grep PermitEmptyPasswords | grep "^[^#;]" 
	if [ $? -eq 0 ]; then
		echo "Cau hinh PermitEmptyPasswords no done" 
	else
		echo "Config PermitEmptyPasswords no" 
		echo "PermitEmptyPasswords no" >> ${cssh}
	fi
	
	# Check cau hinh dong bo thoi gian 
	cat ${cntp} | grep server | grep iburst | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		sed -i 's/server 0.centos.pool.ntp.org iburst/# server 0.centos.pool.ntp.org iburst/g' ${cntp}
		sed -i 's/server 1.centos.pool.ntp.org iburst/# server 1.centos.pool.ntp.org iburst/g' ${cntp}
		sed -i 's/server 2.centos.pool.ntp.org iburst/# server 2.centos.pool.ntp.org iburst/g' ${cntp}
		sed -i 's/server 3.centos.pool.ntp.org iburst/# server 3.centos.pool.ntp.org iburst/g' ${cntp}
	fi
	
	cat ${cntp} | grep server | grep "10.36.32.13" | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Cau hinh server 10.36.32.13 done" 
	else
		echo "Config server 10.36.32.13" 
		echo "server 10.36.32.13" >> ${cntp}
		systemctl restart ntpd
	fi
	
	# Cau hinh log monitoring snmpd.conf csnmp
	cat ${csnmp} | grep lvbsnmpkey | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh key done" 
	else
		echo "#       sec.name        source          community
com2sec ConfigUser      default         lvbsnmpkey
" >> ${csnmp}
		systemctl restart snmpd
	fi
	
	# Cau hinh log center rsyslog.conf
	cat ${crsyslog} | grep 514 | grep "^[^#;]"
	if [ $? -eq 1 ]; then
		echo "Chua cau hinh rsyslog"
		read -p "Cau hinh log may chu ve HCM hay BNI?" choice
		if [[ $choice == "HCM" ]]; then
			echo "HCM"
			echo "*.*  @10.16.243.11:514" >> ${crsyslog}
			systemctl restart  rsyslog
		elif [[ $choice == "BNI" ]]; then
			echo "BNI"		
			echo "*.*  @10.36.207.15:514 " >> ${crsyslog}
			systemctl restart  rsyslog
		else
			echo "Ban chua chon dung"
		fi
	else
		echo "Cau hinh rsyslog OK"
	fi
	
	# Cau hinh mat khau toi da 6 thang PASS_MAX_DAYS 90
	cat ${clogin} | grep "PASS_MAX_DAYS" | grep 99999 | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Cau hinh hien tai la PASS_MAX_DAYS   99999" 
		cd /etc/ && chmod +x login.defs
		sed -i 's/^PASS_MAX_DAYS.*99999/PASS_MAX_DAYS   90/g' ${clogin}
		chmod -x login.defs
	else
		cat ${clogin} | grep "PASS_MAX_DAYS" | grep "^[^#;]"
	fi
	
	# Cau hinh password co do dai toi thieu 8 ky tu va co do dai phuc tap 
	 cat ${cpam} | grep password  | grep  pam_pwquality | grep authtok_type | grep "^[^#;]"
        if [ $? -eq 0 ]; then
                echo "Comment cau hinh hien tai"
                sed -i 's/^password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=.*/#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=/g' ${cpam}
                echo "password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root" >> ${cpam}
        else
                cat ${cpam} | grep "" | grep "^[^#;]"
        fi
	
else
	echo "Current user is not root"
fi
