#!/bin/bash

echo -e "\t* Skidam arkade koji ce posle instalirati druge alate"
wget https://github.com/alexellis/arkade/releases/download/$ARKADE_VER/arkade -O arkade > /dev/null 2>&1

echo -e "\t* Prebacujem u /usr/local/bin"
chmod +x arkade
sudo mv arkade /usr/local/bin

echo -e "\t* Instaliram software uz pomoc arkade"

# Ubaci u niz software koji zelis da se instalira uz pomoc arkade
declare -a arkade_to_install=("k9s" "kubectl"  
   "krew" "helm" "helmfile"
   #"run-job" "popeye" "polaris"
   #"kubectx" "kubecolor" "kube-linter" "kops"
   "kubeval" "kubetail" "kubeseal" "kubens"
   "jq" "fzf" "cilium" "hubble" "argocd" "argocd-autopilot" )


for i in "${arkade_to_install[@]}"
do
   echo -e "\t\t- $i"
   arkade get $i >/dev/null 2>&1
done


echo -e "\t* Prebacujem skinuti software u /usr/local/bin"
chmod +x $HOME/.arkade/bin/*
sudo mv $HOME/.arkade/bin/* /usr/local/bin/


echo -e "\t* Kopiram kube precice"
cp scripts/kube.stuff $HOME/.kube.stuff
if grep -q .kube.stuff  $HOME/.bashrc; then
   echo -e "\t* .kube.stuff vec postoji u .bashrc"
else
   echo -e "\t* .kube.stuff upisujem u .bashrc"
   echo "source $HOME/.kube.stuff" >> $HOME/.bashrc
   source $HOME/.bashrc    
fi