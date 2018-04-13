execute "install nscd" do
    Chef::Log.debug("nscd - intalling")
    command "yum install nscd -y"
end

service "nscd" do
  action [ :enable, :start ]
end