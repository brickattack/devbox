# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

MEMORY=2048
CORES=2

Vagrant.configure(VAGRANTFILE_API_VERSION) do |web|
  web.vm.box = 'Ubuntu1204LTS'
  web.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  web.vm.provider :virtualbox do |v|
    # Use VBoxManage to customize the VM. For example to change memory:
    v.customize ["modifyvm", :id, "--memory", MEMORY.to_i]
    v.customize ["modifyvm", :id, "--cpus", CORES.to_i]

    if CORES.to_i > 1
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
  end

  web.vm.network 'forwarded_port', guest: 3000, host: 8080
  web.vm.network 'forwarded_port', guest: 5432, host: 3001
  web.ssh.forward_agent = true

  web.vm.provision 'shell', path: 'vagrant/setup.sh'
end
