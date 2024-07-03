#!/bin/bash

#setting up hostnames
echo "172.16.0.1 master"   | sudo tee -a /etc/hosts > /dev/null
echo "172.16.0.11 worker1" | sudo tee -a /etc/hosts > /dev/null
echo "172.16.0.12 worker2" | sudo tee -a /etc/hosts > /dev/null
sudo systemctl restart systemd-hostnamed

#disabling password authentification for ssh
sudo sed 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo service ssh restart