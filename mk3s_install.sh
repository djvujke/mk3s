#!/bin/bash
# Neke stvari uzete sa linka
# https://www.armand.nz/notes/k3s/Install%20K3s%20with%20Cilium%20single-node%20cluster%20on%20Debian

# Exit on any error
set -e

# Load print helper functions
source "$(dirname "$0")/scripts/print_helper.sh"

# Main installation header
cprint "K3s + Cilium Installation" 0 "equal"
if [[ $EUID -eq 0 ]]; then
   cprint_error "Ova skripta ne sme da se pokrece kao root! Ali trazi sudo"
fi

cprint "Ucitavam promenljive iz my_k3s_cluster.config fajla" 0 "dash"
if ! source "$(dirname "$0")/configs/my_k3s_cluster.config"; then
    cprint_error "Greska: Fajl my_k3s_cluster.config ne postoji!" 0 "bracket"
fi

cprint "Skidam k3s bez traefik-a, kube-proxy-ja, flanena, servicelb i network-policy-ja" 0 "dash"
export INSTALL_K3S_EXEC=" --flannel-backend=none --disable-network-policy --disable servicelb --disable traefik"
curl -sfL https://get.k3s.io | sh -

cprint "Namestam kubeconfig" 0 "dash"
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config

if grep -q KUBECONFIG $HOME/.bashrc; then
  cprint "KUBECONFIG postoji vec u .bashrc-u" 1
else
  cprint "Upisujem KUBECONFIG u .bashrc" 1
  echo "export KUBECONFIG=$HOME/.kube/config" >> $HOME/.bashrc
  source $HOME/.bashrc
fi

cprint "Pokrecem skriptu spremi_alate.sh" 0 "dash"
./scripts/spremi_alate.sh

cprint "Instaliram cilium" 0 "dash"
if grep -q bpf  /etc/fstab; then
    cprint "Proveravam bpf...bpf postoji vec u /etc/fstab-u" 1 "star"
else
    cprint "Proveravam bpf...Upisujem u /etc/fstab" 1 "star"
    sudo mount bpffs -t bpf /sys/fs/bpf
    sudo bash -c 'cat <<EOF >> /etc/fstab
none /sys/fs/bpf bpf rw,relatime 0 0
EOF'
    
    sudo systemctl daemon-reload
    sudo systemctl restart local-fs.target
fi

cprint "Dodajem Cilium Helm repo" 1 "star"
helm repo add cilium https://helm.cilium.io/
helm repo update

cprint "Kreiram privremene yaml fajlove" 1 "star"
envsubst '${CILIUM_LB_IP},${CILIUM_NAMESPACE}' < yaml/values.yaml > yaml/my-values.yaml
envsubst '${CILIUM_LB_IP}' < yaml/lb-ipam.yaml > yaml/my-lb-ipam.yaml
envsubst '${CILIUM_NAMESPACE}' < yaml/announce.yaml > yaml/my-announce.yaml

cprint "Instaliram Cilium" 1 "star"
helm upgrade --install cilium cilium/cilium \
	--version $CILIUM_VERSION \
	--create-namespace \
	--namespace $CILIUM_NAMESPACE \
	--set operator.replicas=1 \
	--set ipam.operator.clusterPoolIPv4PodCIDRList=$CILIUM_CLUSTER_CIDR \
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

cprint "Primenjujem Cilium konfiguracije" 1 "star"
kubectl apply -f yaml/my-announce.yaml
kubectl apply -f yaml/my-lb-ipam.yaml

cprint "Brisem privremene fajlove" 1 "star"
rm -f yaml/my-lb-ipam.yaml yaml/my-values.yaml yaml/my-announce.yaml

cprint "Proveravam status Cilium-a" 1 "star"
cilium -n$CILIUM_NAMESPACE status --wait

cprint_success "K3s + Cilium instalacija je zavrsena uspesno!"
cprint "Mozete pokrenuti './verify_installation.sh' za proveru" 0
