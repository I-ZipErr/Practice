#!/bin/bash
# disabling SWAP (файл подкачки) file, Kubernetes requires it for stable work
echo -e "\n\n==========Swap disabling started!=========="
sudo swapoff -a  
sudo sed -i '/ swap / s/^/#/' /etc/fstab
echo "===============Swap disabled!=============="
 # openning ports for k8s node installation
 # list of required ports: https://v1-27.docs.kubernetes.io/docs/reference/networking/ports-and-protocols/
echo  -e "\n\n==========Ports opening started!==========="
iptables -I INPUT 1 -p tcp --match multiport --dports 10250,30000:32767 -j ACCEPT
#sudo ufw allow 10250/tcp 
#sudo ufw allow 30000:32767/tcp  
echo "================Ports opened!==============="
 # forwarding IPv4 and letting iptables see bridged traffic for Kubernetes container runtimes
 # see: https://v1-27.docs.kubernetes.io/docs/setup/production-environment/container-runtimes/
echo  -e "\n\n==========Forwarding IPv4 started!==========="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
echo "================Forwarding IPv4 finished!==============="
 # setting up hostnames for Kubernetes nodes
echo  -e "\n\n======Hostnames setting up started======="
sudo echo -e "\n172.16.0.1 master">>/etc/hosts
sudo echo -e "\n172.16.0.11 worker1">>/etc/hosts
sudo echo -e "\n172.16.0.12 worker2">>/etc/hosts
echo "======Hostnames setting up finished======"
 # installing Docker as Container Runtimes for Kubernetes + cri-dockerd
 # Docker Engine installation guide: 
 # https://docs.docker.com/engine/install/
echo  -e "\n\n=======Docker installation started!========"
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
 # cri-dockerd placed in vagrantfile directory
sudo dpkg -i /vagrant/cri-dockerd_0.3.14.3-0.ubuntu-jammy_amd64.deb
systemctl enable --now cri-docker.socket
echo "=========Docker installed finished!========="
 # kubeadm installation for Debian-based Linux
 # see https://v1-27.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
echo  -e "\n\n=====Kubernetes installation started!======"
sudo apt-get update
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
