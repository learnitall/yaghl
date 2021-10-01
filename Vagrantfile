# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "generic/centos8"
  config.vm.network "public_network", auto_config: false
  config.vm.network "public_network", auto_config: false

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "scripts/mgmt-cluster-install.yaml"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 2
  end

end
