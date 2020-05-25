#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export HOSTNAME="${domain}"

echo "${certificate}" > /etc/ssl/$HOSTNAME.crt
echo "${key}" > /etc/ssl/$HOSTNAME.key
chmod 644 /etc/ssl/$HOSTNAME.*

echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" >> /etc/resolv.conf

# Harden SSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g; s/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl reload ssh

# Disable ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Set hostname
hostnamectl set-hostname $HOSTNAME
echo -e "127.0.0.1 localhost $HOSTNAME" >> /etc/hosts

apt-get -y update
apt-get -y upgrade
apt-get -y install apt-transport-https

# Install Java if Debian 9 or earlier
os_version=$(lsb_release -r | cut -f2 | awk -F '.' '{ print $1 }')
if [[ $os_version -le 9 ]]; then
    apt-get -y install openjdk-8-jre-headless
    echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile
    source /etc/profile
fi

# Install Nginx
apt-get -y install nginx
systemctl start nginx.service
systemctl enable nginx.service

# Add Jitsi to sources
apt-get -y install gnupg
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
apt-get -y update
echo -e "DefaultLimitNOFILE=65000\nDefaultLimitNPROC=65000\nDefaultTasksMax=65000" >> /etc/systemd/system.conf
systemctl daemon-reload

# Configure Jitsi install
echo "jitsi-videobridge jitsi-videobridge/jvb-hostname string $HOSTNAME" | debconf-set-selections
echo "jitsi-meet jitsi-meet/cert-choice select I want to use my own certificate" | debconf-set-selections

# Install Jitsi 
apt-get -y install jitsi-meet

# Increase default screen sharing frame rate
sed -i "s|    // desktopSharingFrameRate: {|    desktopSharingFrameRate: {\n        min: 15,\n        max: 30\n    },|g" /etc/jitsi/meet/$HOSTNAME-config.js

# Configure jicofo
sed -i 's/authentication = "anonymous"/authentication = "internal_plain"/g' /etc/prosody/conf.avail/$HOSTNAME.cfg.lua
echo -e "\nVirtualHost \"guest.$HOSTNAME\"\n    authentication = \"anonymous\"\n    c2s_require_encryption = false" >> /etc/prosody/conf.avail/$HOSTNAME.cfg.lua
sed -i "s|// anonymousdomain: 'guest.example.com',|anonymousdomain: \'guest.$HOSTNAME\',|g" /etc/jitsi/meet/$HOSTNAME-config.js
echo "org.jitsi.jicofo.auth.URL=XMPP:$HOSTNAME" >> /etc/jitsi/jicofo/sip-communicator.properties
systemctl restart prosody jicofo jitsi-videobridge2
prosodyctl register "${jitsi_user_name}" $HOSTNAME '${jitsi_password}'
