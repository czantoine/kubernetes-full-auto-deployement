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

# Install minikube
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod 755 /usr/local/bin/minikube

# Install K8s
echo "Installing Kubernetes..."
sudo apt install kubeadm -y

# Start minikube
sudo minikube start --driver=none

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

# Deployment 
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/Dockerfile 
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/flaskapi.py
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/secrets.yml
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/mysql-pv.yml
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/mysql-deployment.yml
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/flaskapp-deployment.yml
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/requirements.txt
wget https://raw.githubusercontent.com/czantoine/kubernetes-full-auto-deployement/main/db.sql

sudo docker pull mysql
sudo docker build . -t flask-api

sudo kubectl apply -f secrets.yml
sudo kubectl apply -f mysql-pv.yml
sudo kubectl apply -f mysql-deployment.yml
sudo kubectl apply -f flaskapp-deployment.yml

sleep 30

pod=$(sudo kubectl get pods | grep mysql | sed 's/\s.*$//')
sudo kubectl exec $pod -i -- /bin/bash -c 'mysql -u root -proot -e "CREATE DATABASE flaskapi"'
sudo kubectl exec $pod -i -- mysql -u root -proot flaskapi < db.sql

sudo kubectl get service

#sudo kubectl run -it --rm --image=mysql --restart=Never mysql-client -- mysql --host mysql --password=


# CREATE TABLE pokemon(pokemon_id INT PRIMARY KEY AUTO_INCREMENT, pokemon_name VARCHAR(255), pokemon_name_en VARCHAR(255), pokemon_number VARCHAR(255));


# curl -H "Content-Type: application/json" -d '{"name": "pikachu", "name_en": "pikachu", "number": "23"}' 192.168.56.30:30204/create
# curl -H "Content-Type: application/json" 192.168.56.30:30204/delete/2
# curl -H "Content-Type: application/json" -d {"name": "bonjour", "name_en": "hellzzo", "number": "23", "pokemon_id": "1"} 192.168.56.30:30204/update


echo "Finished !"