#!/bin/bash

KUBEADM_VERSION=${KUBEADM_VERSION:-1.33.0}
CRICTL_VERSION=${CRICTL_VERSION:-1.33.0}
RELEASE_VERSION=0.18.0

curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz" | sudo tar -C /usr/bin/ -xz
curl -L --remote-name-all https://dl.k8s.io/v${KUBEADM_VERSION}/bin/linux/amd64/kubeadm
curl -L --remote-name-all https://dl.k8s.io/v${KUBEADM_VERSION}/bin/linux/amd64/kubelet
curl -L --remote-name-all https://dl.k8s.io/v${KUBEADM_VERSION}/bin/linux/amd64/kubectl

chmod +x kubeadm
chmod +x kubelet
chmod +x kubectl

curl -sSL "https://raw.githubusercontent.com/kubernetes/release/v${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sudo tee /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/v${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# TODO: Do we need luet?
#COPY +luet/luet /usr/bin/luet

# Setup containerd
mkdir -p /opt/cni/bin
curl -sSL https://github.com/containerd/containerd/releases/download/v1.6.4/containerd-1.6.4-linux-amd64.tar.gz | sudo tar -C /opt/ -xz
curl -SL -o runc "https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64"
curl -sSL https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz | sudo tar -C /opt/cni/bin/ -xz
install -m 755 runc /opt/bin/runc
curl -sSL "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" | sed "s?ExecStart=/usr/local/bin/containerd?ExecStart=/opt/bin/containerd?" | sudo tee /etc/systemd/system/containerd.service

cp -R /opt/bin/ctr /usr/bin/ctr
mkdir -p /opt/kubeadm/scripts

bash /opt/kubeadm/scripts/kube-images-load.sh ${KUBEADM_VERSION}

echo "overlay" >> /etc/modules-load.d/k8s.conf
echo "br_netfilter" >> /etc/modules-load.d/k8s.conf
echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.d/k8s.conf
echo net.bridge.bridge-nf-call-ip6tables=1 >> /etc/sysctl.d/k8s.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.d/k8s.conf