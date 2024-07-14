#!/bin/bash

echo -e "Skidam k3s bez traefik-a, kube-proxy-ja, flanena, servicelb i network-policy-ja\n"
curl -sfL https://get.k3s.io | sh -s - \
  --flannel-backend=none \
  --disable-kube-proxy \
  --disable servicelb \
  --disable-network-policy \
  --disable traefik \
  --cluster-init

echo -e "\nNamestam kubeconfig"
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config


if grep -q KUBECONFIG $HOME/.bashrc; then
    echo -e "\nKUBECONFIG postoji vec u .bashrc-u" 
else
    echo -e "Upisujem KUBECONFIG u .bashrc"
    echo "export KUBECONFIG=$HOME/.kube/config" >> $HOME/.bashrc
fi


echo -e "Pokrecem spremi_alate.sh"
./spremi_alate.sh
