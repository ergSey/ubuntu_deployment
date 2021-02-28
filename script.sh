#!/bin/bash -xv

#necessary packages installation
apt update
apt install -y vim iotop tcpdump redis-server net-tools iptables-persistent

#private network configuration
sed -i '/    ens34:/{N;s/    ens34:\n      dhcp4: true/    ens34:\n      dhcp4: no\n      addresses: \[172\.20\.80\.100\/24\, ]\n      gateway4: 192\.168\.59\.144\n      nameservers:\n                addresses: [192.168.59.144, ]/}' /etc/netplan/00-installer-config.yaml
netplan apply

#new users addition based on the user list file
newusers ./userlist

#public keys addition for each users
user=$(cat ./userlist | grep "/bin/bash" |  awk -F':' '{print$1}')
groupadd privileged
for var in $(echo $user)
     do
        mkdir /home/$var/.ssh
        cat ./pubkeys/"$var"_id_rsa.pub > /home/$var/.ssh/authorized_keys
        chown -R $var:$var /home/$var/.ssh
        chmod 700 /home/$var/.ssh
        chmod 600 /home/$var/.ssh/authorized_keys
        usermod -a -G privileged $var
     done

#assigning privileged rights to the users
echo "%privileged ALL=(ALL) ALL" > /etc/sudoers.d/privileged

#ssh/sftp server configuration
sed -i 's/#Port 22/Port 58257/; s/#PubkeyAuthentication yes/PubkeyAuthentication yes/; s/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd.service

#redis server configuration
sed -i 's/supervised no/supervised systemd/; s/bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf
systemctl restart redis.service

#firewall configuration
ufw disable
iptables-restore < ./iptrules
iptables-save > /etc/iptables/rules.v4

