# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

config.vm.define "ubuntu-xenial" do |subconfig|
 IP = "192.168.20.12"
	  subconfig.vm.box = "ubuntu/xenial64" 
	  subconfig.vm.hostname="ubuntu-xenial"
	  subconfig.vm.network :private_network, ip: IP
	  
	  subconfig.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
		vb.cpus = "2"
		vb.gui = false
		
		disk1 = "disk23.vdi"
			
		unless FileTest.exist?(disk1)
			vb.customize ['createhd', '--filename', disk1, '--size', 10 * 1024]
		end 

		# Attach the drives to the SCSI controller
		vb.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', disk1] 
	  end
	 
	  subconfig.vm.provision "shell", path: "ub-provision.sh", env: {
	  "IP"=>IP
	  }
  end
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
