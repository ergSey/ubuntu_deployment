#!/bin/bash -xv

apt update
apt install -y vim iotop tcpdump redis-server net-tools

sed -i '/    ens34:/{N;s/    ens34:\n      dhcp4: true/    ens34:\n      dhcp4: no\n      addresses: \[172\.20\.80\.100\/24\, ]\n      gateway4: 192\.168\.59\.144\n      nameservers:\n                addresses: [192.168.59.144, ]/}' /etc/netplan/00-installer-config.yaml

netplan apply

newusers ./userlist

user=$(cat ./userlist | grep "/bin/bash" |  awk -F':' '{print$1}')
groupadd privileged
for var in $(echo $user)
     do
        mkdir /home/$var/.ssh
        cat pubkeys/'$var'_id_rsa.pub > /home/$var/.ssh/authorized_keys
        chown -R $var:$var /home/$var/.ssh
        chmod 700 /home/$var/.ssh
        chmod 600 /home/$var/.ssh/authorized_keys
        usermod -a -G privileged $var
     done

echo "%privileged ALL=(ALL) ALL" > /etc/sudoers.d/privileged
sed -i '/#Port 22/Port 58257/'
sed -i '/#PubkeyAuthentication yes/PubkeyAuthentication yes/'
sed -i '/PasswordAuthentication yes/PasswordAuthentication no/'


