# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.define "kali" do |subconfig|
		subconfig.vm.box = "kalilinux/rolling"
		subconfig.vm.box_version = "2020.2.1"
		subconfig.vm.hostname="kali"
		subconfig.vm.network :private_network, ip: "192.168.55.11"   
		subconfig.vm.provision "shell", path: "provision.sh"
		subconfig.vm.box_check_update = false
		subconfig.vm.boot_timeout = 600
		subconfig.vm.provider "virtualbox" do |vb|      
			#vb.memory = "1024"      
			#vb.cpus = "1"   
			vb.gui = false
		end
	end
end
