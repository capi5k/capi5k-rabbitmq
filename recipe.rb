set :rabbitmq_path, "#{recipes_path}/capi5k-rabbitmq"

load "#{rabbitmq_path}/roles.rb"
load "#{rabbitmq_path}/roles_definition.rb"
load "#{rabbitmq_path}/output.rb"

set :puppet_p, "http_proxy=http://proxy:3128 https_proxy=http://proxy:3128 puppet"

before :rabbitmq, :puppet

namespace :rabbitmq do

  desc 'Deploy RabbitMQ on nodes'
  task :default do
    generate
    modules::install
    transfer
    apply
    web_stomp_plugin
  end


  task :generate do
    template = File.read("#{file_rabbitmq_manifest}")
    renderer = ERB.new(template)
    myFile = File.open("#{rabbitmq_path}/tmp/rabbitmq.pp", "w")
    generate = renderer.result(binding)
    myFile.write(generate)
    myFile.close
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

  task :web_stomp_plugin, :roles =>[:rabbitmq] do
    set :user, "root"
    run "wget http://public.rennes.grid5000.fr/~msimonin/web_stomp_plugin/web_stomp_plugin_2.8.2.tar.gz 2>1"
    run "tar -xvzf web_stomp_plugin_2.8.2.tar.gz"
    run "cp web_stomp_plugin_2.8.2/* /usr/lib/rabbitmq/lib/rabbitmq_server-2.8.4/plugins/."
    run "rabbitmq-plugins enable rabbitmq_web_stomp"
    run "rabbitmq-plugins enable rabbitmq_web_stomp_examples"
    run "service rabbitmq-server restart"
  end

end

