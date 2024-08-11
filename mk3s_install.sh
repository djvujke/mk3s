#!/bin/bash
# Neke stvari uzete sa linka
# https://www.armand.nz/notes/k3s/Install%20K3s%20with%20Cilium%20single-node%20cluster%20on%20Debian

echo -e "- Ucitavam promenljive iz my_k3s_cluster.config fajla"
source ./my_k3s_cluster.config


echo -e "- Skidam k3s bez traefik-a, kube-proxy-ja, flanena, servicelb i network-policy-ja\n"
export INSTALL_K3S_EXEC=" --flannel-backend=none --disable-network-policy --disable servicelb --disable traefik"
curl -sfL https://get.k3s.io | sh -


echo -e "\n- Namestam kubeconfig"
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config


if grep -q KUBECONFIG $HOME/.bashrc; then
	echo -e "\t...KUBECONFIG postoji vec u .bashrc-u" 
else
	echo -e "\t...Upisujem KUBECONFIG u .bashrc"
	echo "export KUBECONFIG=$HOME/.kube/config" >> $HOME/.bashrc
	source $HOME/.bashrc
fi


echo -e "\n- Pokrecem skriptu spremi_alate.sh"
./scripts/spremi_alate.sh


echo -e "\n- Instaliram cilium"
if grep -q bpf  /etc/fstab; then
    echo -e "\t* Proveravam bpf...bpf postoji vec u /etc/fstab-u"
else
    echo -e "\t* Proveravam bpf...Upisujem u /etc/fstab"
    sudo mount bpffs -t bpf /sys/fs/bpf
    sudo bash -c 'cat <<EOF >> /etc/fstab
    none /sys/fs/bpf bpf rw,relatime 0 0
    EOF'
    
    sudo systemctl daemon-reload
    sudo systemctl restart local-fs.target
fi

echo -e "\n- Instaliram cilum u namespace $CILIUM_NAMESPACE, verzija $CILIUM_VERSION"
export CILIUM_LB_IP=$(hostname -I|cut -d ' ' -f1)

envsubst '${CILIUM_LB_IP}' < yaml/lb-ipam.yaml > yaml/my-lb-ipam.yaml
envsubst '${CILIUM_LB_IP}' < yaml/values.yaml > yaml/my-values.yaml


helm repo add cilium https://helm.cilium.io/
helm repo update
helm upgrade --install cilium cilium/cilium \
	--version $CILIUM_VERSION \
	--create-namespace \
	--namespace $CILIUM_NAMESPACE \
	--set operator.replicas=1 \
	--set ipam.operator.clusterPoolIPv4PodCIDRList=$CILIUM_CLUSTER_CIDR\
	--set ipv4NativeRoutingCIDR=$CILIUM_CLUSTER_CIDR \
	--set ipv4.enabled=true \
	--set loadBalancer.mode=dsr \
	--set kubeProxyReplacement=strict \
	--set routingMode=native \
	--set autoDirectNodeRoutes=true \
	--set hubble.relay.enabled=true \
	--set hubble.ui.enabled=true \
	--set l2announcements.enabled=true \
	-f yaml/my-values.yaml

kubectl apply -f yaml/announce.yaml
# envsubst '${CILIUM_LB_IP}' < yaml/lb-ipam.yaml | 
kubectl apply -f yaml/my-lb-ipam.yaml

rm -f yaml/my-lb-ipam.yaml yaml/my-values.yaml


cilium -n$CILIUM_NAMESPACE status --wait
