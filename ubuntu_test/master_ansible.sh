#!/bin/bash

#setting up hostnames
echo "172.16.0.1 master"   | sudo tee -a /etc/hosts > /dev/null
echo "172.16.0.11 worker1" | sudo tee -a /etc/hosts > /dev/null
echo "172.16.0.12 worker2" | sudo tee -a /etc/hosts > /dev/null
sudo systemctl restart systemd-hostnamed

#pipx installation
sudo apt-get update
sudo apt-get -y install pipx
#somewhat doesn't apply
export PATH="$PATH:/home/vagrant/.local/bin"
echo export PATH="$PATH:/home/vagrant/.local/bin" | sudo tee -a /home/vagrant/.bashrc > /dev/null
#pipx needs to reload console for the autocompletion to start working
#uncomment in case; source does the same thing, exec creates completly new instance
#exec bash
source ~/.bashrc
eval "$(register-python-argcomplete pipx)"
#ansible installation
#https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
pipx install --include-deps ansible
pipx inject --include-apps ansible argcomplete
#ansible_become_password: vagrant
#ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_private_key_file=/mnt/d/Practice/ubuntu_test/worker2.pub

#sudo cp $HOME/.ssh/*.pub /vagrant/"$HOSTNAME"_ssh.pub
#sudo echo $(</vagrant/worker1_ssh.pub) >> ~/.ssh/authorized_keys
#sudo echo $(</vagrant/worker2_ssh.pub) >> ~/.ssh/authorized_keys
#sudo echo $(</vagrant/master_ssh.pub) >> ~/.ssh/authorized_keys
#echo -e "\n\n\n" |ssh-copy-id -i $HOME/.ssh/id_ed25519.pub vagrant@worker1

#generating ssh key and sending it to hosts, needs manual password input
#TODO: use ssh agent + /.ssh/config file to use different keys for different machines
ssh-keygen -t ed25519 -N "" -P "" -f $HOME/.ssh/id_ed25519
ssh-copy-id -i $HOME/.ssh/id_ed25519.pub vagrant@worker1
#ssh-add
ssh-copy-id -i $HOME/.ssh/id_ed25519.pub vagrant@worker2
#ssh-add
ssh-copy-id -i $HOME/.ssh/id_ed25519.pub vagrant@master
#ssh-add
#ssh-add -l
#disabling password authentification for ssh
sudo sed 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo service ssh restart