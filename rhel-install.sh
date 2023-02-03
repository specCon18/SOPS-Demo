#!/bin/sh
SOPS_LATEST_VERSION=$(curl -s "https://api.github.com/repos/mozilla/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
AGE_LATEST_VERSION=$(curl -s "https://api.github.com/repos/FiloSottile/age/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo sops.rpm "https://github.com/mozilla/sops/releases/download/v$SOPS_LATEST_VERSION/sops-$SOPS_LATEST_VERSION-1.x86_64.rpm"
sudo dnf localinstall sops.rpm -y
rm -rf sops.rpm
curl -Lo age.tar.gz "https://github.com/FiloSottile/age/releases/latest/download/age-v${AGE_LATEST_VERSION}-linux-amd64.tar.gz"
tar xf age.tar.gz
sudo mv age/age /usr/local/bin
sudo mv age/age-keygen /usr/local/bin
rm -Rf age age.tar.gz
echo "Sops Version: $(sops -v)"
echo "Age Version: $(age -version)"
echo "Age-Keygen Version: $(age-keygen -version)"