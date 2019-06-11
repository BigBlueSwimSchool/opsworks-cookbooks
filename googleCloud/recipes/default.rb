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
      :type => node[:googleCloud][:type],
      :project_id => node[:googleCloud][:project_id],
      :private_key_id => node[:googleCloud][:private_key_id],
      :private_key => node[:googleCloud][:private_key].gsub(/(\n)/){|match|"\\\n"},
      :client_email => node[:googleCloud][:client_email],
      :client_id => node[:googleCloud][:client_id],
      :auth_uri => node[:googleCloud][:auth_uri],
      :token_uri => node[:googleCloud][:token_uri],
      :auth_provider_x509_cert_url => node[:googleCloud][:auth_provider_x509_cert_url],
      :client_x509_cert_url => node[:googleCloud][:client_x509_cert_url]
    )
  end

  link "#{deploy[:deploy_to]}/current/googleCloud.json" do
    action :create
    link_type :symbolic
    to "#{deploy[:deploy_to]}/shared/config/googleCloud.json"
  end

end