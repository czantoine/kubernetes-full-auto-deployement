Vagrant.configure("2") do |config|
        config.vm.provision :shell, path: "scripts/conf.sh"
        config.vm.boot_timeout = 1000
        config.vm.define "master" do |master|
		master.vm.box = "bento/ubuntu-20.04"
		master.vm.hostname= "master"
		master.vm.network "private_network", ip: "192.168.56.30"
		master.vm.provider "virtualbox" do |v|
			v.memory = 4096
			v.cpus = 4
			v.name = "master"
                 	v.gui = true 
               end
               master.vm.provision :shell, path: "auto/master_deployement.sh" 
	end
        config.vm.define "worker1" do |worker1|
		worker1.vm.box = "bento/ubuntu-20.04"
		worker1.vm.hostname= "worker1"
		worker1.vm.network "private_network", ip: "192.168.56.31"
		worker1.vm.provider "virtualbox" do |v|
			v.memory = 2048
			v.cpus = 1
			v.name = "worker1"
			v.gui = true
		end
	        worker1.vm.provision :shell, path: "auto/worker_deployement.sh"
	end
	config.vm.define "worker2" do |worker2|
		worker2.vm.box = "bento/ubuntu-20.04"
		worker2.vm.hostname= "worker2"
		worker2.vm.network "private_network", ip: "192.168.56.32"
		worker2.vm.provider "virtualbox" do |v|
			v.memory = 2048
			v.cpus = 1
			v.name = "worker2"
			v.gui = true
		end
		worker2.vm.provision :shell, path: "auto/worker_deployement.sh"
	end
end