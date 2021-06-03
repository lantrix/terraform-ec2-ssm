#!/bin/bash 
yum install -y git vim zlib-devel jq python37
yum group install -y "Development Tools"
su - ec2-user -c "gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
su - ec2-user -c "\curl -sSL https://get.rvm.io | bash -s stable"
su - ec2-user -c "rvm install ruby-2.7.2" #amazon-linux-2 binary
su - ec2-user -c "gem install homesick"
su - ec2-user -c "homesick clone lantrix/dotfiles"
su - ec2-user -c "homesick link dotfiles --force"
su - ec2-user -c "git config --global --unset url.git@github.com:.insteadof"
su - ec2-user -c "homesick clone lantrix/dotfiles-vim"
su - ec2-user -c "homesick link dotfiles-vim --force"
su - ec2-user -c "vim +PluginInstall +qall 1>/dev/null"
su - ec2-user -c "curl -O https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py --user && rm ~/get-pip.py"
su - ec2-user -c "pip install --user powerline-status"
# Golang
su - ec2-user -c "curl -LO https://golang.org/dl/go1.16.4.linux-amd64.tar.gz && sudo tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz && rm ~/go1.16.4.linux-amd64.tar.gz && mkdir -p ~/go/{src,bin}"
su - ec2-user -c "vim +GoInstallBinaries +qall 1>/dev/null"
