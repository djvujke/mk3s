#!/bin/bash

ARKADE_VER=0.11.17
echo "Skidam arkade koji ce posle instalirati druge alate"
wget https://github.com/alexellis/arkade/releases/download/$ARKADE_VER/arkade -O arkade > /dev/null 2>&1

echo "Prebacujem u /usr/local/bin"
chmod +x arkade
sudo mv arkade /usr/local/bin

echo "Instaliram kubectl, helm, krew...."
arkade get kubectl krew helm helmfile \
    run-job popeye polaris \
    kubeval kubetail kubeseal kubens kubectx \
    kubecolor kube-linter ktop kops k9s \
    jq fzf cilium hubble argocd argocd-autopilot

chmod +x $HOME/.arkade/bin/*

echo "Prebacujem skinuti software u /usr/local/bin"
sudo mv $HOME/.arkade/bin/* /usr/local/bin/


echo -e "Kopiram kube precice"
cp kube.stuff $HOME/.kube.stuff
echo "source $HOME/.kube.stuff" >> $HOME/.bashrc
