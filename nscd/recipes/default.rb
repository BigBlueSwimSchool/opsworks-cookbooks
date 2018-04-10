execute "install nscd" do
    Chef::Log.debug("nscd - intalling")
    command "yum -y nscd"
end

service "nscd" do
  action [ :enable, :start ]
end