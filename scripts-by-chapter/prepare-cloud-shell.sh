#!/usr/bin/env bash

echo "---------- INSTALLING NANO ----------"
sudo yum install nano -y

echo "---------- INSTALLING EKSCTL ----------"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.177.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
# https://github.com/eksctl-io/eksctl/releases/download/v0.177.0/eksctl_Linux_amd64.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

echo "---------- INSTALLING HELM ----------"
export VERIFY_CHECKSUM=false
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash