#!/bin/bash
# FOR UBUNTU 20.04.2 LTS
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
#sudo name=$(cat /etc/hostname)
#PUBLIC_IP_ADDRESS=`hostname -I|cut -d" " -f 1`
#sudo echo "${PUBLIC_IP_ADDRESS}  $name" >> /etc/hosts
sudo apt-get purge aufs-tools docker-ce docker-ce-cli containerd.io pigz cgroupfs-mount -y
sudo apt-get purge kubeadm kubernetes-cni -y
sudo rm -rf /etc/kubernetes
sudo rm -rf $HOME/.kube/config
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/docker
sudo rm -rf /opt/containerd
sudo apt autoremove -y

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Setup Daemon
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo bash -c "cat > /etc/docker/daemon.json"<<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart docker
sudo usermod -aG docker $USER
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "Setting up Kubernetes Package Repository..."
sudo apt-get install apt-transport-https curl -y 
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add 
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo "Installing Kubernetes..."
sudo apt install kubeadm -y
sudo kubeadm init --apiserver-advertise-address=192.168.56.30 --pod-network-cidr=10.244.0.0/16
sudo sleep 10
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Installing Flannel..."
export KUBECONFIG=$HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
echo "Kubernetes Installation finished..."
echo "Waiting 30 seconds for the cluster running..."
sudo sleep 30

echo "Testing Kubernetes namespaces... "
kubectl get pods --all-namespaces
echo "Testing Kubernetes nodes... "
kubectl get nodes

sudo kubeadm token create --print-join-command > /vagrant/token
echo "Token deployed..."
sleep 30
sudo apt install pip python -y

# Deployement k8s
kubectl create namespace k8s-webapp
echo "Namespaces k8s-webapp created..."

# Database only k8S mysql 
#wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/secret.yaml
#wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/mysql-service.yml
#wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/mysql-deployment.yaml

#sudo kubectl apply -f secret.yaml
#sudo kubectl apply -f mysql-deployment.yaml
#sleep 5
#sudo kubectl apply -f mysql-service.yaml
#sleep 15


echo "Finished !"