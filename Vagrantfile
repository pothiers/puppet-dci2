# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  #! Do this before using: vagrant plugin install vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    config.cache.scope       = :box
  end

  #! Do this before using: vagrant plugin install vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provision "shell",
    inline: "yum upgrade -y puppet" #! Remove for production!!!

  config.vm.synced_folder "..", "/sandbox"
  config.vm.synced_folder "../data", "/data"
  config.vm.synced_folder "/home/pothiers/data", "/fitsdata"  
  config.vm.box     = 'centos65'
  config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'

  config.vm.define "mountain" do |mountain|
    mountain.vm.network :private_network, ip: "172.16.1.11"
    mountain.vm.hostname = "mountain.test.noao.edu"
    mountain.hostmanager.aliases =  %w(mountain)

    mountain.vm.provision :puppet do |puppet|
      puppet.manifests_path = "mountain/manifests"
      puppet.module_path = "mountain/modules"
      puppet.manifest_file = "init.pp"
      #!puppet.manifests_path = "manifests"
      #!puppet.module_path = "modules"
      #!puppet.manifest_file = "role/tadamountain.pp"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       '--debug', #+++ #! Remove for production!!!
      ]
    end
  end

  config.vm.define "valley" do |valley|
    valley.vm.network :private_network, ip: "172.16.1.12"
    valley.vm.hostname = "valley.test.noao.edu"
    valley.hostmanager.aliases =  %w(valley)

    valley.vm.provision :puppet do |puppet|
      puppet.manifests_path = "valley/manifests"
      puppet.module_path = "valley/modules"
      puppet.manifest_file = "init.pp"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       '--debug', #+++
      ]
    end
  end

end
