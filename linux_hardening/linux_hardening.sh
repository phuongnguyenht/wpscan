#! /bin/bash
#
# * @description: Check Hardening Server Linux
# * @author  Nolove
# * @version 1.0

cssh="/etc/ssh/sshd_config"
cntp="/etc/ntp.conf"
csnmp="/etc/snmp/snmpd.conf"
crsyslog="/etc/rsyslog.conf"
clogin="/etc/login.defs"
cpam="/etc/pam.d/system-auth"
cpasswd="/etc/passwd"

# check current user
cUser=`whoami`
echo "Current user is: " $cUser
if [[ $cUser == "root" ]]
then
	echo -e "Begin running and check hardening \n"

	# 1.1 Disable ssh by user root
	echo -e "\033[1m1.1 Disable ssh by user root\033[0m"
	cat ${cssh} | grep PermitRootLogin | grep "^[^#;]" | grep yes 
	[ $? -eq 0 ] && sudo sed -i 's/PermitRootLogin yes/# PermitRootLogin yes/g' ${cssh} || echo "Comment PermitRootLogin yes done"
	cat ${cssh} | grep PermitRootLogin | grep "^[^#;]" | grep no
	if [ $? -eq 0 ]; then
		echo "Cau hinh PermitRootLogin no done" 
	else
		echo "Cau hinh PermitRootLogin no " 
		# echo "PermitRootLogin no" >> ${cssh}
	fi
	echo "-------------------------------------------------- "
	
	# 1.2 Vo hieu hoa tai khoan khong su dung
	echo -e "\033[1m1.2 Vo hieu hoa tai khoan khong su dung\033[0m"
	echo "List danh sach tai khoan da tao "
	cat ${cpasswd} | grep /bin/bash | awk -F ":" '{print $1}'
	# TH muon disable tai khoan 
	# usermod -s /sbin/nologin username
	echo "-------------------------------------------------- "
	
	# 1.3 Kiem tra phan quyen nguoi dung va tap tin tren he thong
	echo -e "\033[1m1.3 Kiem tra phan quyen nguoi dung va tap tin tren he thong\033[0m"
	if [[ "$(stat -c '%a' /etc/security)" == "750" ]]
	then
		echo " Permissions /etc/security = 750"
	else
		chmod 750 /etc/security
	fi
	listVar="/etc/passwd /etc/group"
	for i in $listVar; do
		if [[ "$(stat -c '%a' $i)" == "644" ]]
		then
			echo "Permissions $i: 644"
		else
			chmod 644 $i
		fi
	done
	echo "-------------------------------------------------- "
	# 1.4 Cau hinh mat khau toi thieu la 8 ki tu bao gom chu hoa, chu thuong, so va ky tu dac biet
	echo -e "\033[1m1.4.1 Cau hinh mat khau toi thieu la 8 ki tu bao gom chu hoa, chu thuong, so va ky tu dac biet\033[0m"
	cat ${cpam} | grep password  | grep  pam_pwquality | grep authtok_type | grep "^[^#;]"
	if [ $? -eq 0 ]; then
			echo "Comment cau hinh hien tai"
			sed -i 's/^password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=.*/#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=/g' ${cpam}
			echo "password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root" >> ${cpam}
	else
			cat ${cpam} | grep "" | grep "^[^#;]"
	fi
	echo -e "\033[1m1.4.2 Cau hinh khong su dung lai 5 mat khau cu gan nhat\033[0m"
	cat ${cpam} | grep password  | grep  pam_unix.so | grep use_authtok | grep try_first_pass | grep "^[^#;]"
	if [ $? -eq 0 ]; then
			cat ${cpam} | grep remember=5 
			if [ $? -eq 0 ]; then
				echo "Da cau hinh remember=5"
			else
				echo "Comment cau hinh hien tai"
				sed -i 's/^password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok.*/#password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok/g' ${cpam}
				echo "password    sufficient   pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" >> ${cpam}
			fi
	else
			cat ${cpam} | grep "" | grep "^[^#;]"
	fi
	echo "-------------------------------------------------- "
	# 1.6 Gioi han mat khau toi da 06 thang
	echo -e "\033[1m1.6 Gioi han mat khau toi da 06 thang \033[0m"
	cat ${clogin} | grep "PASS_MAX_DAYS" | grep 99999 | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Cau hinh hien tai la PASS_MAX_DAYS   99999" 
		cd /etc/ && chmod +x login.defs
		sed -i 's/^PASS_MAX_DAYS.*99999/PASS_MAX_DAYS   90/g' ${clogin}
		chmod -x login.defs
	else
		cat ${clogin} | grep "PASS_MAX_DAYS" | grep "^[^#;]"
	fi
	echo "-------------------------------------------------- "
	# 1.7 Gioi han thoi gian khi nguoi dung khong tuong tac voi server ClientAliveInterval 300   ClientAliveCountMax 0
	echo -e "\033[1m1.7 Gioi han thoi gian khi nguoi dung khong tuong tac voi server \033[0m"
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
	echo "-------------------------------------------------- "
	# 1.8 Khong cho user co password rong dang nhap PermitEmptyPasswords no
	echo -e "\033[1m1.8 Khong cho user co password rong dang nhap \033[0m"
	cat ${cssh} | grep PermitEmptyPasswords | grep "^[^#;]" | grep yes
	[ $? -eq 0 ] && sudo sed -i 's/PermitEmptyPasswords/# PermitEmptyPasswords/g' ${cssh} || echo "Comment PermitEmptyPasswords yes done. Default PermitEmptyPasswords no"
	cat ${cssh} | grep PermitEmptyPasswords | grep "^[^#;]" 
	if [ $? -eq 0 ]; then
		echo "Cau hinh PermitEmptyPasswords no done" 
	else
		echo "Config PermitEmptyPasswords no" 
		echo "PermitEmptyPasswords no" >> ${cssh}
	fi
	cat ${cssh} | grep PasswordAuthentication | grep no | grep "^[^#;]" 
	[ $? -eq 0 ] && sudo sed -i 's/PasswordAuthentication/# PasswordAuthentication/g' ${cssh} || echo "Comment PasswordAuthentication done. Default PasswordAuthentication yes"
	echo "-------------------------------------------------- "
	# 1.9 Change port ssh
	echo -e "\033[1m1.9 Change port ssh \033[0m"
	echo "Default mo port 22. Chua co chinh sach change sang port khac"
	echo "-------------------------------------------------- "
	# 2.0 Gioi han so lan dang nhap ssh sai
	echo -e "\033[1m2.0 Gioi han so lan dang nhap ssh sai \033[0m"
	cat ${cssh} | grep MaxAuthTries | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh MaxAuthTries done" 
	else
		echo "Cau hinh MaxAuthTries = 3" 
		echo "MaxAuthTries = 3" >> ${cssh}
	fi	
	echo "-------------------------------------------------- "
	# 2.1 Cau hinh Protocol ssh
	echo -e "\033[1m2.1 Cau hinh Protocol ssh \033[0m"
	cat ${cssh} | grep Protocol | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh Protocol done" 
	else
		echo "Protocol 2" >> ${cssh}
	fi	
	echo "-------------------------------------------------- "
	# 2.2 Cau hinh Ma hoa trong ssh
	echo -e "\033[1m2.2 Cau hinh Ma hoa trong ssh \033[0m"
	cat ${cssh} | grep Ciphers | grep aes | grep ctr | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh Ciphers done" 
	else
		echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> ${cssh}
	fi	
	cat ${cssh} | grep KexAlgorithms | grep sha2 | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh KexAlgorithms done" 
	else
		echo "KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521" >> ${cssh}
	fi	
	echo "-------------------------------------------------- "
	# 2.3 Cau hinh log ssh
	echo -e "\033[1m2.3 Cau hinh log ssh \033[0m"
	cat ${cssh} | grep LogLevel | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh LogLevel done" 
	else
		echo "LogLevel VERBOSE" >> ${cssh}
	fi	
	echo "-------------------------------------------------- "
	
	echo -e "\033[1mNetwork and Firewall \033[0m"
	# 2.2 Kiem tra Thong so co ban: IP tinh, Subnet mask, Gateway, DNS Server DNS HCM: 10.16.192.21-22;
    # DNS Server Bac Ninh: 10.36.22.11-12
	
	echo -e "\033[1m2.2 Kiem tra Thong so co ban: IP tinh, Subnet mask, Gateway, DNS Server \033[0m"
	echo -e " IP: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep IPADDR | awk -F "=" '{print $2}')"
	echo -e " NETMASK: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep PREFIX | awk -F "=" '{print $2}')"
	echo -e " GATEWAY: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep GATEWAY | awk -F "=" '{print $2}')"
	echo -e " DNS: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep DNS | awk -F "=" '{print $2}')"
	echo "-------------------------------------------------- "
	
	# 3.3 Check cau hinh dong bo thoi gian 
	echo -e "\033[1m3.3 Check cau hinh dong bo thoi gian \033[0m"
	if [ -f "${cntp}" ]; then
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
	
	else
		echo "\033[1m Chua cai NTP \033[0m"
	fi
	echo "-------------------------------------------------- "
	
	# 4.1 Cau hinh log monitoring snmpd.conf 
	echo -e "\033[1m4.1 Cau hinh log monitoring snmpd.conf \033[0m"
	if [ -f "${csnmp}" ]; then
		cat ${csnmp} | grep lvbsnmpkey | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh key done" 
	else
		echo "#       sec.name        source          community
com2sec ConfigUser      default         lvbsnmpkey
" >> ${csnmp}
		systemctl restart snmpd
	fi
	else
		echo "\033[1m Chua cai SNMP \033[0m"
	fi
	
	echo "-------------------------------------------------- "
	# 4.3 Cau hinh log ve may chu luu log trung tam
	# Cau hinh log center rsyslog.conf
	cat ${crsyslog} | grep 514 | grep "^[^#;]"
	if [ $? -eq 1 ]; then
		echo "Chua cau hinh rsyslog"
		subIP=`ifconfig $(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) |awk '/inet/ {print $2}' | cut -d "." -f1-2`
		if [[ $subIP == "10.16" ]]; then
			echo "*.*  @10.16.243.11:514" >> ${crsyslog}
			systemctl restart  rsyslog
		elif [[ $subIP == "10.36" ]]; then	
			echo "*.*  @10.36.207.15:514 " >> ${crsyslog}
			systemctl restart  rsyslog
		else
			echo "Cau hinh rsyslog"
		fi
	else
		echo "Cau hinh rsyslog truoc do roi"
	fi
	echo "-------------------------------------------------- "
	
else
	echo "Current user is not root"
fi