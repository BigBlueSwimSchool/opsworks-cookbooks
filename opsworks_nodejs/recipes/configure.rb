node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs application #{application} as it is not a node.js app")
    next
  end

  template "#{deploy[:deploy_to]}/shared/config/opsworks.js" do
    cookbook 'opsworks_nodejs'
    source 'opsworks.js.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :database => deploy[:database],
      :db_cluster => node[:db_cluster],
      :memcached => node[:memcached], 
      :layers => node[:opsworks][:layers],
      :services => node[:services],
      :models => node[:models],
      :aws => node[:aws],
      :elasticsearch => node[:elasticsearch]
    )
  end

  template "#{deploy[:deploy_to]}/shared/config/env.js" do
    cookbook 'opsworks_nodejs'
    source 'env.js.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :environment => deploy[:environment]
      )
  end

  template "#{deploy[:deploy_to]}/shared/config/.env" do
    cookbook 'opsworks_nodejs'
    source 'dotenv.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :environment => deploy[:environment]
      )
  end
  
end
