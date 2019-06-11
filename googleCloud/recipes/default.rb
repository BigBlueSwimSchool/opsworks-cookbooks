node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::googleCloud application #{application} as it is not a node.js app")
    next
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