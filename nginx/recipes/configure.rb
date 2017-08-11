directory "#{node[:nginx][:dir]}/app.d/" do
  owner "root"
  group "root"
  mode 0755
  not_if { File.exist?("#{node[:nginx][:dir]}/app.d/") }
end

node[:deploy].each do |application, deploy|
  
  template "#{node[:nginx][:dir]}/conf.d/#{application}.conf" do
    source 'upstream.conf.erb'
    owner "root"
    group "root"
    mode 0644
    variables(
      :application_name => application
    )
  end

  template "#{node[:nginx][:dir]}/app.d/#{application}.conf" do
    source 'app.conf.erb'
    owner "root"
    group "root"
    mode 0644
    variables(
      :application_name => application,
      :route => deploy[:environment][:route]
    )
  end
end

template "#{node[:nginx][:dir]}/conf.d/api.conf" do
  source "api.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

include_recipe "nginx::service"

Chef::Log.debug("nginx: restarting nginx")

service "nginx" do
  action :restart
end