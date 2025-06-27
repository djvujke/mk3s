#!/bin/bash

# Exit on any error
set -e

# Load print helper functions
source "$(dirname "$0")/print_helper.sh"

cprint "Skidam arkade koji ce posle instalirati druge alate" 1 "star"
if ! wget https://github.com/alexellis/arkade/releases/download/$ARKADE_VER/arkade -O arkade > /dev/null 2>&1; then
    cprint_error "Neuspesno preuzimanje arkade!"
fi

cprint "Prebacujem u /usr/local/bin" 1 "star"
chmod +x arkade
if ! sudo mv arkade /usr/local/bin; then
    cprint_error "Neuspesno prebacivanje arkade u /usr/local/bin!"
fi

cprint "Instaliram software uz pomoc arkade" 1 "star"

# Ubaci u niz software koji zelis da se instalira uz pomoc arkade
declare -a arkade_to_install=("k9s" "kubectl"  
   "krew" "helm" "helmfile"
   #"run-job" "popeye" "polaris"
   #"kubectx" "kubecolor" "kube-linter" "kops"
   "kubeval" "kubetail" "kubeseal" "kubens"
   "jq" "fzf" "cilium" "hubble" "argocd" "argocd-autopilot" )

for i in "${arkade_to_install[@]}"
do
   cprint "$i" 2
   arkade get $i >/dev/null 2>&1
done

cprint "Prebacujem skinuti software u /usr/local/bin" 1 "star"
chmod +x $HOME/.arkade/bin/*
sudo mv $HOME/.arkade/bin/* /usr/local/bin/

cprint "Kopiram kube precice" 1 "star"
cp scripts/kube.stuff $HOME/.kube.stuff
if grep -q .kube.stuff  $HOME/.bashrc; then
   cprint ".kube.stuff vec postoji u .bashrc" 2
else
   cprint ".kube.stuff upisujem u .bashrc" 2
   echo "source $HOME/.kube.stuff" >> $HOME/.bashrc
   source $HOME/.bashrc    
fi
