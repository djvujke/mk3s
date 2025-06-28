#!/bin/bash

# Exit on any error
set -e

# Load print helper functions
source "$(dirname "$0")/print_helper.sh"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Path to the file you want to source (one directory up)
PARENT_DIR="$(dirname "$SCRIPT_DIR")" 
FILE_TO_SOURCE="$PARENT_DIR/configs/my_k3s_cluster.config"
source $FILE_TO_SOURCE


cprint "Skidam arkade (version: $ARKADE_VER) koji ce posle instalirati druge alate" 1 "star"
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
declare -A ARKADE_APPS=(
    ["k9s"]="v0.50.6"
    ["kubectl"]="v1.33.2"
    ["krew"]="v0.4.5"
    ["helm"]=""
    ["helmfile"]=""
    ["kubeval"]=""
    ["kubetail"]=""
    ["kubeseal"]=""
    ["kubens"]=""
    ["jq"]=""
    ["fzf"]=""
    ["cilium"]="v0.18.4"
    ["hubble"]="v1.17.5"
    ["argocd"]=""
    ["argocd-autopilot"]=""
)



for app in "${!ARKADE_APPS[@]}"; do
  version="${ARKADE_APPS[$app]}"
  fullapp=$app
  if [ -n "$version" ]; then
     fullapp="$app@$version"
  fi
  cprint "Installing: $fullapp" 3 "star"
  arkade get "$fullapp" >/dev/null 2>&1
done

cprint "Prebacujem skinuti software u /usr/local/bin" 1 "star"
chmod +x $HOME/.arkade/bin/*
sudo mv $HOME/.arkade/bin/* /usr/local/bin/

cprint "Kopiram kube precice" 1 "star"
cp "$(dirname "$0")/kube.stuff" "$HOME/.kube.stuff"
if grep -q .kube.stuff  $HOME/.bashrc; then
   cprint ".kube.stuff vec postoji u .bashrc" 2
else
   cprint ".kube.stuff upisujem u .bashrc" 2
   echo "source $HOME/.kube.stuff" >> $HOME/.bashrc
   source $HOME/.bashrc
fi
