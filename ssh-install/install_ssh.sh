#!/bin/bash
# Description: Install openssh-server

# install ssh
if [ ! -f /etc/ssh/sshd_config ]; then
	apt install ssh -y
fi
sudo=''
if [ "$(whoami)" != "root" ]; then
    sudo="sudo "
fi
# check and configuration
if [ "$(${sudo} cat /etc/ssh/sshd_config | grep '^PermitRootLogin')" != "PermitRootLogin yes" ]; then
	${sudo} echo PermitRootLogin yes >> /etc/ssh/sshd_config
fi
if [ "$(${sudo} cat /etc/ssh/sshd_config | grep '^RSAAuthentication')" != "RSAAuthentication yes" ]; then
	${sudo} echo RSAAuthentication yes >> /etc/ssh/sshd_config
fi
if [ "$(${sudo} cat /etc/ssh/sshd_config | grep '^PubkeyAuthentication')" != "PubkeyAuthentication yes" ]; then
	${sudo} echo PubkeyAuthentication yes >> /etc/ssh/sshd_config
fi
# cach viet khac cua if then
[ "$(${sudo} cat /etc/ssh/sshd_config | grep '^PasswordAuthentication yes')" != "PasswordAuthentication yes" ] && { ${sudo} echo PasswordAuthentication yes >> /etc/ssh/sshd_config; }

systemctl enable ssh
service ssh restart
