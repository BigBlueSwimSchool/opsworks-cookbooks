
template "#{node[:nginx][:dir]}/conf.d/prerender.io.conf" do
  source "prerender.io.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :server_name => node[:server_name],
    :client_protocol => node[:client_protocol],
    :prerender => node[:prerender],
    :proxy => node[:proxy]
    :locations => node[:locations]
  )
end

include_recipe "nginx::service"

Chef::Log.debug("nginx: restarting nginx")

service "nginx" do
  action :restart
end