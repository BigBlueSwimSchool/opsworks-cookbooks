define :opsworks_nodejs do
  deploy = params[:deploy_data]
  application = params[:app]

  node[:dependencies][:npms].each do |npm, version|
    execute "/usr/local/bin/npm install #{npm}" do
      cwd "#{deploy[:deploy_to]}/current"
    end
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

  template "/etc/init.d/#{application}" do
    source 'node_web_app.init.d.erb'
    cookbook 'opsworks_nodejs'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      :deploy => deploy,
      :application_name => application
    )
  end

  template "#{node[:nginx][:dir]}/conf.d/#{application}.conf" do
    cookbook 'nginx'
    source 'upstream.conf.erb'
    owner "root"
    group "root"
    mode 0644
    variables(
      :application_name => application
    )
    only_if { deploy[:environment][:route] }
  end

  directory "#{node[:nginx][:dir]}/app.d/" do
    owner "root"
    group "root"
    mode 0755
    not_if { File.exist?("#{node[:nginx][:dir]}/app.d/") }
  end
  
  template "#{node[:nginx][:dir]}/app.d/#{application}.conf" do
    cookbook 'nginx'
    source 'app.conf.erb'
    owner "root"
    group "root"
    mode 0644
    variables(
      :application_name => application,
      :route => deploy[:environment][:route]
    )
    only_if { deploy[:environment][:route] }
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

  link "#{deploy[:deploy_to]}/current/env.js" do
    action :create
    link_type :symbolic
    to "#{deploy[:deploy_to]}/shared/config/env.js"
  end

  template "#{deploy[:deploy_to]}/shared/config/.env" do
    cookbook 'opsworks_nodejs'
    source 'dotenv.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :global => node[:environment],
      :environment => deploy[:environment]
      )
  end

  link "#{deploy[:deploy_to]}/current/.env" do
    action :create
    link_type :symbolic
    to "#{deploy[:deploy_to]}/shared/config/.env"
  end

  template "#{deploy[:deploy_to]}/shared/config/newrelic.js" do
    cookbook 'newrelic'
    source 'newrelic.js.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :application => deploy[:application].gsub('_', '-'),
      :license_key => node[:newrelic][:license],
      :environment => node[:newrelic][:environment],
      :application_type => deploy[:application_type]
    )
  end

  link "#{deploy[:deploy_to]}/current/newrelic.js" do
    action :create
    link_type :symbolic
    to "#{deploy[:deploy_to]}/shared/config/newrelic.js"
  end

  template "#{deploy[:deploy_to]}/shared/config/googleCloud.json" do
    cookbook 'googleCloud'
    source 'googleCloud.json.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :googleCloud => node[:googleCloud]
    )
  end

  link "#{deploy[:deploy_to]}/current/googleCloud.json" do
    action :create
    link_type :symbolic
    to "#{deploy[:deploy_to]}/shared/config/googleCloud.json"
  end

end
