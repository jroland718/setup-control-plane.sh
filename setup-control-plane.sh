#!/bin/bash

set -e

echo "Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo "Adding CRI-O repository..."
OS="xUbuntu_22.04"
VERSION="1.28" # Match your Kubernetes version
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/libcontainers.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list

echo "Installing CRI-O..."
sudo apt-get update
sudo apt-get install -y cri-o cri-o-runc
sudo systemctl enable crio
sudo systemctl start crio

echo "Adding Kubernetes repository..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Installing kubeadm, kubectl, and kubelet..."
sudo apt-get update
sudo apt-get install -y kubeadm kubectl kubelet
sudo apt-mark hold kubeadm kubectl kubelet

echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Initializing the Kubernetes control plane..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

echo "Configuring kubectl for the admin user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Installing Calico network plugin..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

echo "Control plane setup complete!"

Worker Node Script

Save this as setup-worker-node.sh and make it executable with chmod +x setup-worker-node.sh.

#!/bin/bash

set -e

echo "Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo "Adding CRI-O repository..."
OS="xUbuntu_22.04"
VERSION="1.28" # Match your Kubernetes version
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/libcontainers.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list

echo "Installing CRI-O..."
sudo apt-get update
sudo apt-get install -y cri-o cri-o-runc
sudo systemctl enable crio
sudo systemctl start crio

echo "Adding Kubernetes repository..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Installing kubeadm, kubectl, and kubelet..."
sudo apt-get update
sudo apt-get install -y kubeadm kubectl kubelet
sudo apt-mark hold kubeadm kubectl kubelet

echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Worker node setup complete!"
echo "To join the cluster, run the kubeadm join command provided during control plane initialization."

Usage Instructions
    1.    Run on Control Plane:
    •    Execute setup-control-plane.sh on your control plane node.
    •    Copy the kubeadm join command output after initialization.
    2.    Run on Worker Nodes:
    •    Execute setup-worker-node.sh on each worker node.
    •    Use the kubeadm join command from the control plane setup to join the cluster:

sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

These scripts will give you a fully functional Kubernetes cluster with Calico and CRI-O on Ubuntu 22.04. Let me know if you need refinements or additional features!
