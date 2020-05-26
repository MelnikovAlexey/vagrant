# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.define "cl1" do |subconfig|
		subconfig.vm.box = "ubuntu/xenial64"
		subconfig.vm.hostname="cl1"
		subconfig.vm.network :private_network, ip: "192.168.55.12"   
		subconfig.vm.provision "shell", path: "provision.sh"
		subconfig.vm.box_check_update = false
		subconfig.vm.boot_timeout = 600
		subconfig.vm.provider "virtualbox" do |vb|      
			vb.memory = "256"      
			vb.cpus = "1"   
			vb.gui = false
		end
	end
	config.vm.define "cl2" do |subconfig|
	  subconfig.vm.box = "ubuntu/xenial64"
	  subconfig.vm.hostname="cl2"
	  subconfig.vm.network :private_network, ip: "192.168.55.13"
	  subconfig.vm.provider "virtualbox" do |vb|
		vb.memory = "256"
		vb.cpus = "1"
		vb.gui = false
	  end
	  subconfig.vm.provision "shell", path: "provision.sh"
	end
end
