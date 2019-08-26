node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs application #{application} as it is not a node.js app")
    next
  end

  template "#{deploy[:deploy_to]}/shared/config/elastic-apm-node.js" do
    cookbook 'elastic_apm'
    source 'elastic-apm-node.js.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(
      :service_name => deploy[:application].gsub('_', '-'),
      :secret_key => node[:elastic_apm][:secret_key],
      :server_url => node[:elastic_apm][:server_url]
    )
  end

  link "#{deploy[:deploy_to]}/current/elastic-apm-node.js" do
    action :create
    link_type :symbolic
    to "#{deploy[:deploy_to]}/shared/config/elastic-apm-node.js"
  end

end
