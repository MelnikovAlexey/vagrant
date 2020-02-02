# -*- mode: ruby -*-
# vi: set ft=ruby :

MACHINES = {
	:kali => {
		:box_name => "kalilinux/rolling",
		:ip_addr=> '192.168.80.101',
		:hostname => 'kali',
		:memory => 2048,
		:name => "kali"	
	},
	:cent => {
		:box_name => "centos/7",
		:ip_addr=> '192.168.80.102',
		:hostname => 'centos',
		:memory => 2048,
		:name => "centos"	
	}
}
Vagrant.configure("2") do |config|
  
  MACHINES.each do |boxname,boxconfig|
	config.vm.define boxname do |box|
		box.vm.box = boxconfig[:box_name]
		box.vm.hostname = boxconfig[:hostname]
		box.vm.network :private_network, ip: boxconfig[:ip_addr]
		box.vm.provider :virtualbox do |vb|
			vb.customize ["modifyvm", :id, "--memory", boxconfig[:memory]]
			vb.customize ["modifyvm", :id, "--name", boxconfig[:name]]
			vb.cpus = 2
			vb.gui = false
		end
	end
	end
end
