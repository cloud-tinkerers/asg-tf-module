#!/bin/bash

exec 2>&1 >> /tmp/boot.log

date

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
client=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Client)
env=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Environment)
app=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Application)
instance_id=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
github_token=$(aws ssm get-parameter --name /production/github/token --with-decryption --query "Parameter.Value" --output text)
cloudflareapi_token=$(aws ssm get-parameter --name /production/cloudflare/token --with-decryption --query "Parameter.Value" --output text)

if ! sudo dnf update -y > /dev/null ; then
    echo "Unable to install updates"
else
    echo "Updates installed successfully"
fi

if ! sudo dnf install -y perl gcc make wget autoconf automake perl-CPAN perl-IO-Socket-SSL aws-cli vim git htop mariadb105-server > /dev/null ; then
    echo "Unable to download required software"
else 
    echo "Software installed"
fi

if ! aws ec2 attach-volume --volume-id vol-01efd5fdb9d7ff41f --instance-id $instance_id --device /dev/sdf ; then
    echo "Unable to attach sitedata volume"
else
    echo "Sitedata volume attached"
fi

if ! sudo mkdir -p /sitedata ; then
    echo "Unable to create client sitedata directory"
else
    echo "Client sitedata directory created"
fi

if ! echo "UUID=ba747f85-a43a-4733-9e6b-9128c9eb5f76 /sitedata xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab ; then
    echo "Unable to update fstab"
else
    echo "fstab updated"
fi

sleep 5s

if ! sudo mount -a ; then
    echo "Unable to mount volume to sitedata dir"
else
    echo "Volume mounted successfully"
fi

sleep 5s

if [ -d "/sitedata/$client.com" ]; then
    echo "Client sitedata directory exists"
else
    echo "Client sitedata directory does not exist."
fi

sudo chown -R 33:33 /sitedata/*

if ! sudo tee -a /etc/ecs/ecs.config > /dev/null <<EOF
ECS_CLUSTER=$app-$env
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
EOF
then
    echo "Unable to update ecs.config file"
else
    echo "ECS config file updated"
fi

# Set up ddclient
cd /tmp
sudo git clone https://github.com/ddclient/ddclient.git

#install ddclient
cd ddclient
sudo ./autogen
sudo ./configure
sudo make
sudo cp ddclient /usr/sbin/

# Create and set permissions for the configuration file
echo "protocol=cloudflare
zone=$client.com
use=web, web=checkip.dyndns.com/, web-skip='IP Address'
password=$cloudflareapi_token
server=api.cloudflare.com/client/v4
$client.com, www.$client.com" | sudo tee /usr/local/etc/ddclient.conf

#giving permission and ownership
sudo chown root:root /usr/local/etc/ddclient.conf
sudo chmod 600 /usr/local/etc/ddclient.conf

#running the command
sudo ddclient -daemon 300 -syslog

echo "End"