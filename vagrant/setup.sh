#!/usr/bin/env bash
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

echo "************************************************************"
echo "Updating packages..."
echo "************************************************************"
sudo apt-get update

echo "************************************************************"
echo "Installing apt-add-repository"
echo "************************************************************"
sudo apt-get install -y python-software-properties
sudo apt-get install -y build-essential git-core ack-grep zip unzip

echo "************************************************************"
echo "Adding ppa:pitti/postgresql ppa:rwky/redis ppa:nginx/stable ppa:chris-lea/node.js"
echo "************************************************************"
sudo apt-add-repository -y ppa:pitti/postgresql
sudo apt-add-repository -y ppa:rwky/redis
sudo apt-add-repository -y ppa:nginx/stable
sudo apt-add-repository -y ppa:chris-lea/node.js
sudo apt-add-repository -y ppa:brightbox/ruby-ng

echo "************************************************************"
echo "Updating packages..."
echo "************************************************************"
sudo apt-get update

echo "************************************************************"
echo "Installing postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2"
echo "************************************************************"
sudo apt-get install -y postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2 postgresql-common postgresql-server-dev-9.2

echo "************************************************************"
echo "Installing postgresql-server-dev-9.2 libpq-dev"
echo "************************************************************"
sudo apt-get install -y postgresql-server-dev-9.2 libpq-dev

echo "************************************************************"
echo "Updating password for user 'postgres'"
echo "************************************************************"
su postgres -c "psql -c \"alter user postgres with password 'postgres';\""

echo "************************************************************"
echo "Creating postgres roles via /vagrant/vagrant/create_roles.sql"
echo "************************************************************"
su postgres -c "psql -f /vagrant/vagrant/create_roles.sql"

echo "************************************************************"
echo "Changing postgres authentication to md5 instead of peer"
echo "************************************************************"
echo "local   all             postgres                                md5
local   all             all                                     md5
host    all             all             0.0.0.0/0               md5
host    all             all             ::1/128                 md5" \
 | sudo tee /etc/postgresql/9.2/main/pg_hba.conf

echo "************************************************************"
echo "Allowing external connections to postgres"
echo "************************************************************"
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/9.2/main/postgresql

echo "************************************************************"
echo "Restarting postgres"
echo "************************************************************"
sudo /etc/init.d/postgresql restart

echo "************************************************************"
echo "Creating /vagrant/config/database.yml"
echo "************************************************************"
cp -f /vagrant/config/database.yml.example /vagrant/config/database.yml

echo "************************************************************"
echo "Installing redis-server"
echo "************************************************************"
sudo apt-get install -y redis-server

echo "************************************************************"
echo "Installing nodejs"
echo "************************************************************"
sudo apt-get install -y nodejs

echo "************************************************************"
echo "Installing nginx"
echo "************************************************************"
sudo apt-get install -y nginx

echo "************************************************************"
echo "Installing prereqs for ruby, postgis, phantom, etc."
echo "************************************************************"
sudo apt-get install -y chrpath libssl-dev libfontconfig1-dev vim libxml2 libxml2-dev libxslt1-dev libxrender-dev libyaml-dev libsqlite3-dev sqlite3 libproj-dev libjson0-dev xsltproc docbook-xsl docbook-mathml


echo "************************************************************"
echo "Installing ruby"
echo "************************************************************"
sudo apt-get install -y ruby rubygems ruby-switch
sudo apt-get install -y ruby1.9.3 ruby2.0 ruby2.1

echo "************************************************************"
echo "Setting default ruby:"
sudo ruby-switch --set ruby2.1
ruby -v
echo "************************************************************"

echo "************************************************************"
echo "Installing imagemagick"
echo "************************************************************"
sudo apt-get install -y imagemagick

echo "************************************************************"
echo "Installing dnsmasq and setting *.dev to 127.0.0.1 locally"
echo "************************************************************"
sudo apt-get install -y dnsmasq
echo "listen-address=127.0.0.1
bind-interfaces
address=/dev/127.0.0.1" \
 | sudo tee /etc/dnsmasq.conf
sudo service dnsmasq stop
sudo service dnsmasq start
echo "option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;
send host-name \"`hostname`\";
prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        netbios-name-servers, netbios-scope, interface-mtu,
        rfc3442-classless-static-routes, ntp-servers,
        dhcp6.domain-search, dhcp6.fqdn,
        dhcp6.name-servers, dhcp6.sntp-servers;" | sudo tee /etc/dhcp/dhclient.conf


echo "************************************************************"
echo "Cleaning up..."
echo "************************************************************"
sudo apt-get autoremove
echo "
. ~/.bashrc

# List direcory contents
alias lsa='ls -lah'
alias l='ls -la'
alias ll='ls -l'
alias la='ls -lA'
alias sl=ls # often screw this up

alias afind='ack-grep -il'

cd /vagrant" | sudo tee /home/vagrant/.bash_profile

sudo chown vagrant:vagrant /home/vagrant/.bash_profile
