#!/usr/bin/env bash

yum install udisks2 -y
yum install mc -y
yum install tree -y
echo -e "polkit.addRule(function(action, subject) {\n if (action.id == \"org.freedesktop.udisks2.filesystem-mount-system\" && subject.isInGroup(\"otus\")) {\n return polkit.Result.YES;\n};\n});" > /etc/polkit-1/rules.d/10-udisks2.rules

grep -qxF 'sshd; *;otus2;!Al' /etc/security/time.conf || echo 'sshd; *;otus2;!Al' >> /etc/security/time.conf

if ! grep -q "pam_time.so"  /etc/pam.d/sshd; then 
sed -nie 'H;${x;s/^\n//;s/account .*$/account required pam_time.so\n&/;p;}' /etc/pam.d/sshd
fi

if [ ! -d "/home/otus3/jail/" ] 
then
    mkdir -p /home/otus3/jail/{bin,lib64}
	cp /bin/{bash,sh} /home/otus3/jail/bin/
	cp /lib64/{ld-2.17.so,ld-linux-x86-64.so.2,libc-2.17.so,libc.so.6,libdl-2.17.so,libdl.so.2,libtinfo.so.5,libtinfo.so.5.9} /home/otus3/jail/lib64/
	chown root /home/otus3
	grep -q 'Match User otus3' /etc/ssh/sshd_config || echo -e "Match User otus3\nChrootDirectory /home/otus3/jail/\nAllowTCPForwarding no\nX11Forwarding no" >> /etc/ssh/sshd_config
	chroot /home/otus3/jail/ /bin/bash
fi