#!/bin/bash -eux

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is a bare systemd-enabled image, the rest is handled by `build.sh`

export DEBIAN_FRONTEND=noninteractive

apt-get -qq update

apt-get -qq -y upgrade

apt-get -qq -y install systemd apt-transport-https ca-certificates socat

remove_files() {
  xargs -n 1 rm -f -v
}

cd /lib/systemd/system/
## TODO add tricks proposed by @marun https://github.com/kubernetes/release/pull/86#issuecomment-248185616
ls sysinit.target.wants/* multi-user.target.wants/* local-fs.target.wants/* | grep -v systemd-tmpfiles-setup.service | remove_files
ls sockets.target.wants/*initctl* | remove_files 
ls graphical.target.wants/* | remove_files
ls /etc/systemd/system/*.wants/* | remove_files
ln -v -f /lib/systemd/system/multi-user.target /lib/systemd/system/default.target

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

## TODO determine the distro
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list

apt-get -qq update

apt-get -qq -y install docker-engine=1.11.2-0~xenial
apt-mark hold docker-engine

apt-get -qq -y install socat
apt-get -qq -y autoremove
apt-get -qq clean

ls /var/lib/apt/lists/* /tmp/* /var/tmp/* | remove_files
