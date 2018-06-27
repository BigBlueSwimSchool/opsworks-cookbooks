# Remove installed version, if it's not the one that should be installed.
# We only support one user space nodejs installation

PACKAGE_BASENAME = "opsworks-nodejs"
LECAGY_PACKAGES = []

pm_helper = OpsWorks::PackageManagerHelper.new(node)
current_package_info = pm_helper.summary(PACKAGE_BASENAME)

if current_package_info.version && current_package_info.version.start_with?(node[:opsworks_nodejs][:version])
  Chef::Log.info("Userspace NodeJS version is up-to-date (#{node[:opsworks_nodejs][:version]})")
else

  packages_to_remove = pm_helper.installed_packages.select do |pkg, version|
    pkg.include?(PACKAGE_BASENAME) || LECAGY_PACKAGES.include?(pkg)
  end

  packages_to_remove.each do |pkg, version|
    package "Remove outdated package #{pkg}" do
      package_name pkg
      action :remove
    end
  end

  script "Install NVM" do
    interpreter "bash"
    user "root"
    code <<-EOH
      curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
      source ~/.bashrc
      nvm install 9.11.1
      n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; sudo cp -r $n/{bin,lib,share} /usr/local
    EOH
  end

  execute "clear npm cache" do
    Chef::Log.debug("nodejs:clear npm cache")
    command "npm cache clear --force"
  end

  execute "install forever" do
    Chef::Log.debug("nodejs:installing forever")
    command "npm install -g forever"
  end

  node[:deploy].each do |application, deploy|

    execute "set npm authToken" do
      Chef::Log.debug("nodejs:set npm authToken")
      command "npm config set //registry.npmjs.org/:_authToken=#{deploy[:environment_variables][:npm_token]}"
    end

  end
  
  execute "Debug" do
    Chef::Log.debug("nodejs:Debug")
    command "ls -la ~/."
  end

end
