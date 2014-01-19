# -*- mode: ruby -*-
# vi: set ft=ruby :

class CloudUbuntuVagrant < VagrantVbguest::Installers::Ubuntu
  def install(opts=nil, &block)
    communicate.sudo('sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list ', opts, &block)
    communicate.sudo('apt-get update', opts, &block)
    communicate.sudo('apt-get -y -q purge virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11', opts, &block)
    @vb_uninstalled = true
    super
  end

  def running?(opts=nil, &block)
    return false if @vb_uninstalled
    super
  end
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

  script =<<SCRIPT
set -e

cat > /etc/apt/sources.list << EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse
EOF

mkdir -p /etc/apt/sources.list.d

if [ ! -f /etc/apt/sources.list.d/vexor.list ] ; then
  echo 'deb http://download.opensuse.org/repositories/home:/dmexe:/vexor:/testing/xUbuntu_12.04/  ./' > /etc/apt/sources.list.d/vexor.list
  curl -s http://download.opensuse.org/repositories/home:/dmexe:/vexor:/testing/xUbuntu_12.04/Release.key | apt-key add -
fi

if [ ! -f /etc/apt/sources.list.d/osc.list ] ; then
  echo 'deb http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_12.04/ ./' > /etc/apt/sources.list.d/osc.list
  curl -s http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_12.04/Release.key | apt-key add -
fi

apt-get -qqy update > /dev/null
apt-get -qy install osc build vx-embeded-ruby vx-embeded-bundler git-core devscripts debhelper > /dev/null
apt-get -qy autoremove > /dev/null

function sd () {
  sudo su -c "$1" vagrant
}

if [ ! -d home:dmexe:vexor:testing ] ; then
  pushd /home/vagrant
  sd "osc co home:dmexe:vexor:testing"
  popd
fi

pushd /vagrant/.tmp/
  sudo su -c "sh build.sh" vagrant
popd

pushd /home/vagrant/home:dmexe:vexor:testing/vx-worker
  sd "rm -rf vx-worker_*"
  sd "cp /vagrant/.tmp/vx-worker_* ."
  status=$(sudo su -c "osc st" vagrant)
  if [ ! -z "${status}" ] ; then
    echo "changes detected: ${status}"
    sd "osc addremove"
    sd "osc ci -m 'bump'"
  fi
popd

SCRIPT

  config.vm.provision :shell, :inline => script
end
