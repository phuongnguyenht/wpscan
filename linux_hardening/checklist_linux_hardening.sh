#! /bin/bash
#
# * @description: Check Hardening Server Linux
# * @author  Nolove
# * @version 1.0

##usermod -s /sbin/nologin testuser
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
	cat ${cssh} | grep PermitRootLogin | grep "^[^#;]" | grep no
	if [ $? -eq 0 ]; then
		echo "Da cau hinh PermitRootLogin no done" 
	else
		echo "Chua cau hinh PermitRootLogin no"
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
		echo "Permissions /etc/security = 750"
	else
		echo "Chua cau hinh Permissions /etc/security = 750"
	fi
	listVar="/etc/passwd /etc/group"
	for i in $listVar; do
		if [[ "$(stat -c '%a' $i)" == "644" ]]
		then
			echo "Da cau hinh Permissions $i: 644"
		else
			echo "Chưa cau hinh Permissions $i"
		fi
	done
	echo "-------------------------------------------------- "
	# 1.4 Cau hinh mat khau toi thieu la 8 ki tu bao gom chu hoa, chu thuong, so va ky tu dac biet
	echo -e "\033[1m1.4.1 Cau hinh mat khau toi thieu la 8 ki tu bao gom chu hoa, chu thuong, so va ky tu dac biet\033[0m"
	cat ${cpam} | grep password  | grep  pam_pwquality | grep authtok_type | grep minlen=8 | grep retry=3 | grep "^[^#;]"
	if [ $? -eq 0 ]; then
			echo "1.4.1 Cau hinh OK"
	else
			echo "1.4.1 Cau hinh NOT OK" 
	fi
	echo -e "\033[1m1.4.2 Cau hinh khong su dung lai 5 mat khau cu gan nhat\033[0m"
	cat ${cpam} | grep password  | grep  pam_unix.so | grep use_authtok | grep try_first_pass | grep remember= | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh remember $(cat ${cpam} | grep password  | grep  pam_unix.so | grep use_authtok | grep try_first_pass | grep remember= | grep "^[^#;]")"
	else
		echo "Chua cau hinh remember"
	fi
	echo "-------------------------------------------------- "
	# 1.6 Gioi han mat khau toi da 06 thang
	echo -e "\033[1m1.6 Gioi han mat khau toi da 06 thang \033[0m"
	cat ${clogin} | grep "PASS_MAX_DAYS" | grep 99999 | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Cau hinh hien tai la PASS_MAX_DAYS   99999" 
	else
		echo "Cau hinh hien tai la $(cat ${clogin} | grep "PASS_MAX_DAYS" | grep "^[^#;]") "
	fi
	echo "-------------------------------------------------- "
	# 1.7 Gioi han thoi gian khi nguoi dung khong tuong tac voi server ClientAliveInterval 300   ClientAliveCountMax 0
	echo -e "\033[1m1.7 Gioi han thoi gian khi nguoi dung khong tuong tac voi server \033[0m"
	cat ${cssh} | grep ClientAliveInterval | grep "^[^#;]" | grep 300
	if [ $? -eq 0 ]; then
		echo "Da Cau hinh ClientAliveInterval 300 done" 
	else
		echo "Chua cau hinh ClientAliveInterval 300" 
	fi	
	cat ${cssh} | grep ClientAliveCountMax | grep "^[^#;]" | grep 0
	if [ $? -eq 0 ]; then
		echo "Da cau hinh ClientAliveCountMax 0 done" 
	else
		echo "Chua cau hinh ClientAliveCountMax 0. Cau hinh hien tai la $(cat ${cssh} | grep ClientAliveCountMax | grep "^[^#;]")" 
	fi
	echo "-------------------------------------------------- "
	# 1.8 Khong cho user co password rong dang nhap PermitEmptyPasswords no
	echo -e "\033[1m1.8 Khong cho user co password rong dang nhap \033[0m"
	cat ${cssh} | grep PermitEmptyPasswords | grep "^[^#;]" | grep yes
	[ $? -eq 0 ] && echo "Chua cau hinh PermitEmptyPasswords no. Default PermitEmptyPasswords no"
	cat ${cssh} | grep PasswordAuthentication | grep no | grep "^[^#;]" 
	[ $? -eq 0 ] && echo "Chua cau hinh PasswordAuthentication yes" || echo "Da cau hinh PasswordAuthentication done. Default PasswordAuthentication yes"
	echo "-------------------------------------------------- "
	# 1.9 Change port ssh
	echo -e "\033[1m1.9 Change port ssh \033[0m"
	echo "Default mo port 22. Chua co chinh sach change sang port khac"
	echo "-------------------------------------------------- "
	# 2.0 Gioi han so lan dang nhap ssh sai
	echo -e "\033[1m2.0 Gioi han so lan dang nhap ssh sai \033[0m"
	cat ${cssh} | grep MaxAuthTries | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh Cau hinh $(cat ${cssh} | grep MaxAuthTries | grep "^[^#;]") done" 
	else
		echo "Chua cau hinh MaxAuthTries = 3" 
	fi	
	echo "-------------------------------------------------- "
	# 2.1 Cau hinh Protocol ssh
	echo -e "\033[1m2.1 Cau hinh Protocol ssh \033[0m"
	cat ${cssh} | grep Protocol | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh Protocol done" 
	else
		echo "Chua cau hinh Protocol 2"
	fi	
	echo "-------------------------------------------------- "
	# 2.2 Cau hinh Ma hoa trong ssh
	echo -e "\033[1m2.2 Cau hinh Ma hoa trong ssh \033[0m"
	cat ${cssh} | grep Ciphers | grep aes | grep ctr | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh $(cat ${cssh} | grep Ciphers | grep "^[^#;]") done" 
	else
		echo "Chua cau hinh Ciphers"
	fi	
	cat ${cssh} | grep KexAlgorithms | grep sha2 | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh $(cat ${cssh} | grep KexAlgorithms | grep "^[^#;]") done" 
	else
		echo "Chua cau hinh KexAlgorithms"
	fi	
	echo "-------------------------------------------------- "
	# 2.3 Cau hinh log ssh
	echo -e "\033[1m2.3 Cau hinh log ssh \033[0m"
	cat ${cssh} | grep LogLevel | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Cau hinh LogLevel $(cat ${cssh} | grep LogLevel | grep "^[^#;]")" 
	else
		echo "Chua cau hinh LogLevel VERBOSE" 
	fi	
	echo "-------------------------------------------------- "
	
	echo -e "\033[1mNetwork and Firewall Check\033[0m"
	# 2.2 Kiem tra Thong so co ban: IP tinh, Subnet mask, Gateway, DNS Server DNS HCM: 10.16.192.21-22;
    # DNS Server Bac Ninh: 10.36.22.11-12
	
	echo -e "\033[1m2.2 Kiem tra Thong so co ban: IP tinh, Subnet mask, Gateway, DNS Server \033[0m"
	echo -e " IP: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep IPADDR | awk -F "=" '{print $2}')"
	echo -e " NETMASK: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep PREFIX | awk -F "=" '{print $2}')"
	echo -e " GATEWAY: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep GATEWAY | awk -F "=" '{print $2}')"
	echo -e " DNS: $(cat /etc/sysconfig/network-scripts/ifcfg-$(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) | grep DNS | awk -F "=" '{print $2}')"
	echo "-------------------------------------------------- "
	
	# 2.3 Check tai khoan khong co password
	cat /etc/shadow |awk -F: '($2==""){print $1}'
	if [ $? -eq 0 ]; then
		echo "Dat password cho user $(cat /etc/shadow |awk -F: '($2==""){print $1}')" 
	fi	
	
	# 3.3 Check cau hinh dong bo thoi gian 
	echo -e "\033[1m3.3 Check cau hinh dong bo thoi gian \033[0m"
	if [ -f "${cntp}" ]; then
		cat ${cntp} | grep server | grep "10.36.32.13" | grep "^[^#;]"
		if [ $? -eq 0 ]; then
			echo "Da cau hinh server 10.36.32.13 done" 
		else
			echo "Chua cau hinh NTP server 10.36.32.13" 
		fi
	else
		echo -e "\033[1m Chua cai NTP \033[0m"
	fi
	echo "-------------------------------------------------- "
	
	# 4.1 Cau hinh log monitoring snmpd.conf 
	echo -e "\033[1m4.1 Cau hinh log monitoring snmpd.conf \033[0m"
	if [ -f "${csnmp}" ]; then
		cat ${csnmp} | grep lvbsnmpkey | grep "^[^#;]"
	if [ $? -eq 0 ]; then
		echo "Da cau hinh key $(cat ${csnmp} | grep lvbsnmpkey | grep "^[^#;]") done" 
	else
		echo "\033[1m Chua cau hinh SNMP\033[0m"
	fi
	else
		echo -e "\033[1m Chua cai SNMP \033[0m"
	fi
	
	echo "-------------------------------------------------- "
	# 4.3 Cau hinh log ve may chu luu log trung tam
	# Cau hinh log center rsyslog.conf
	cat ${crsyslog} | grep 514 | grep "^[^#;]"
	if [ $? -eq 1 ]; then
		echo -e "\033[1mChua cau hinh rsyslog\033[0m"
		ifconfig $(ip a | grep 2: | awk -F ":" '{print $2}' | xargs) |awk '/inet/ {print $2}' 	
	else
		echo "Cau hinh rsyslog truoc do roi"
	fi
	echo "-------------------------------------------------- "
	
else
	echo "Current user is not root"
fi