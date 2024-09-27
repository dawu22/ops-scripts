#!/bin/bash

update() {
  sudo apt update
  sudo apt upgrade -y
  sudo apt install unzip jq -y
}

##install aws cli
aws_cli() {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
}

##install kubectl
kubectl() {
version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc
}

##install eksctl
eksctl() {
  # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
  ARCH=amd64
  PLATFORM=$(uname -s)_$ARCH
  curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
  # (Optional) Verify checksum
  curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
  tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
  sudo mv /tmp/eksctl /usr/local/bin
  echo '. <(eksctl completion bash)' >> ~/.bashrc
  source ~/.bashrc
}


##install helm3
helm3() {
  curl "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" | bash
}

##install terraform
terraform() {
  wget https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
  unzip -q terraform_1.9.5_linux_amd64.zip
  sudo mv terraform /usr/local/bin
  rm -f LICENSE.txt terraform_1.9.5_linux_amd64.zip
  #terraform -install-autocomplete
}

update
aws_cli
kubectl
eksctl
helm3
terraform
