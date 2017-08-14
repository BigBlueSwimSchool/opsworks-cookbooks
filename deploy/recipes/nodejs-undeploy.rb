include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs-undeploy for application #{application} as it is not a node.js app")
    next
  end

  ruby_block "stop node.js application #{application}" do
    block do
      Chef::Log.info("stop node.js via: #{node[:deploy][application][:nodejs][:stop_command]}")
      Chef::Log.info(`#{node[:deploy][application][:nodejs][:stop_command]}`)
      $? == 0
    end
  end

  file "/etc/init.d/#{application}" do
    action :delete
    only_if do
      ::File.exists?("/etc/init.d/#{application}")
    end
  end

  file "#{node[:nginx][:dir]}/conf.d/#{application}.conf" do
    action :delete
    only_if do
      ::File.exists?("#{node[:nginx][:dir]}/conf.d/#{application}.conf")
    end
  end

  file "#{node[:nginx][:dir]}/app.d/#{application}.conf" do
    action :delete
    only_if do
      ::File.exists?("#{node[:nginx][:dir]}/app.d/#{application}.conf")
    end
  end

  directory "#{deploy[:deploy_to]}" do
    recursive true
    action :delete

    only_if do
      ::File.exists?("#{deploy[:deploy_to]}")
    end
  end
end

service "nginx" do
  action :restart
end
