#!/bin/bash
osdist=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')
echo The Linux Distribution is $osdist
osversion=$(cat /etc/os-release | awk -F '=' '/^VERSION_ID/{print $2}' | awk '{print $1}' | tr -d '"')
echo OS version is $osversion
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
echo AWS Region is: $EC2_REGION

#To install SSM Agent on CentOS 7.x
if [ -f /etc/redhat-release ]; then
  echo "This system is $osdist"
  sudo yum update -y
  cd /tmp
  sudo yum install -y https://s3.$EC2_REGION.amazonaws.com/amazon-ssm-$EC2_REGION/latest/linux_amd64/amazon-ssm-agent.rpm
  sudo systemctl enable amazon-ssm-agent
  sudo systemctl start amazon-ssm-agent
fi

#SSM Agent is installed, by default, on Ubuntu Server 20.04, 18.04, and 16.04 LTS 64-bit AMIs with an identifier of 20180627 or later.
if [ -f /etc/lsb-release ]; then
  echo "This system is $osdist"
  case $osversion in
          "18.04" )
                  sudo apt-get update -y
                  sudo snap start amazon-ssm-agent
                  ;;
  esac
#To install SSM Agent on Ubuntu Server 16.04 and 14.04 64-bit instances (with deb installer package)
elif [ -f /etc/lsb-release ]; then
  echo "This system is $osdist"
  sudo apt-get update -y
  mkdir /tmp/ssm
  cd /tmp/ssm
  wget https://s3.$EC2_REGION.amazonaws.com/amazon-ssm-$EC2_REGION/latest/debian_amd64/amazon-ssm-agent.deb
  sudo dpkg -i amazon-ssm-agent.deb
  sudo systemctl enable amazon-ssm-agent
  sudo start amazon-ssm-agent
fi
