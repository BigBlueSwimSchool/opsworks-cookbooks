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

  log "downloading" do
    message "Download and install NodeJS version #{node[:opsworks_nodejs][:full_version]} patch #{node[:opsworks_nodejs][:patch]} release #{node[:opsworks_nodejs][:pkgrelease]}"
    level :info

    action :nothing
  end

  execute "install nvm" do
    Chef::Log.debug("install nvm")
    command "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash"
  end

  execute "setup nvm" do
    interpreter "bash"
    user "root"
    Chef::Log.debug("setup nvm 1")
    command "source ~/.bashrc"
  end

  execute "install nodejs" do
    Chef::Log.debug("install nodejs")
    command "nvm install 6.11.1"
  end

  execute "install forever" do
    Chef::Log.debug("nodejs:installing forever")
    command "npm install -g forever"
  end
  
end
