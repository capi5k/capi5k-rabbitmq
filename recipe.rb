set :rabbitmq_path, "#{recipes_path}/capi5k-rabbitmq"

load "#{rabbitmq_path}/roles.rb"
load "#{rabbitmq_path}/roles_definition.rb"
load "#{rabbitmq_path}/output.rb"

set :puppet_p, "http_proxy=http://proxy:3128 https_proxy=http://proxy:3128 puppet"

namespace :rabbitmq do

  desc 'Deploy RabbitMQ on nodes'
  task :default do
    puppet
    generate
    modules::install
    transfer
    apply
  end


  task :generate do
    template = File.read("#{file_rabbitmq_manifest}")
    renderer = ERB.new(template)
    myFile = File.open("#{rabbitmq_path}/tmp/rabbitmq.pp", "w")
    generate = renderer.result(binding)
    myFile.write(generate)
    myFile.close
  end

  task :puppet, :roles => [:rabbitmq] do
    set :user, "root"
    run "apt-get update 2>/dev/null"
    run "apt-get install -y puppet 2>/dev/null"
  end

  namespace :modules do
    task :install, :roles => [:rabbitmq] do
      set :user, "root"
      run "#{puppet_p} module install puppetlabs/rabbitmq --version 2.1.0"
   end

    task :uninstall, :roles => [:rabbitmq] do
      set :user, "root"
      run "#{puppet_p} module uninstall puppetlabs/rabbitmq "
   end

  end


  task :transfer, :roles => [:rabbitmq] do
    set :user, "root"
    upload("#{rabbitmq_path}/tmp/rabbitmq.pp","/tmp/rabbitmq.pp", :via => :scp)  
  end


  task :apply, :roles => [:rabbitmq] do
    set :user, "root"
    run "#{puppet_p} apply /tmp/rabbitmq.pp "
  end

end

