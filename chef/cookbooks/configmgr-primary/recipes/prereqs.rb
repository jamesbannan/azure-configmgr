#
# Cookbook:: configmgr-primary
# Recipe:: prereqs
#
# Copyright:: 2017, The Authors, All Rights Reserved.

nuget_path = ::File.join(ENV['programfiles'], 'PackageManagement\\ProviderAssemblies')

powershell_script 'NuGet_Install' do
  code <<-EOH
    Install-PackageProvider -Name NuGet -Force
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    (Get-ChildItem "#{nuget_path}" | Where-Object {$_.Name -eq 'nuget'}) -ne $null
  EOH
end

ps_module_path = ::File.join(ENV['programfiles'], 'WindowsPowerShell\\Modules')

powershell_script 'PowerShell_Module_Install' do
  code <<-EOH
    $modules = [array]@#{node['configmgr-primary']['nuget_modules']}
    foreach($module in $modules){Install-Module -Name $module -Force | Import-Module}
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $modules = [array]@#{node['configmgr-primary']['nuget_modules']}
    $modulePath = "#{ps_module_path}"
    foreach($module in $modules){(Get-ChildItem $modulePath | Where-Object {$_.Name -eq $module}).Name -ne $null}
  EOH
end

dsc_resource 'NetFx35_Install' do
  resource :windowsfeature
  property :name, 'Net-FrameWork-Features'
  property :ensure, 'Present'
end

dsc_resource 'RDC_Install' do
  resource :windowsfeature
  property :name, 'RDC'
  property :ensure, 'Present'
end

dsc_resource 'BITS_Install' do
  resource :windowsfeature
  property :name, 'BITS'
  property :ensure, 'Present'
  property :IncludeAllSubFeature, true
end

dsc_resource 'WebServer_Install' do
  resource :windowsfeature
  property :name, 'Web-Server'
  property :ensure, 'Present'
end

dsc_resource 'ISAPI_Install' do
  resource :windowsfeature
  property :name, 'Web-ISAPI-Ext'
  property :ensure, 'Present'
end

dsc_resource 'WindowsAuth_Install' do
  resource :windowsfeature
  property :name, 'Web-Windows-Auth'
  property :ensure, 'Present'
end

dsc_resource 'IISMetabase_Install' do
  resource :windowsfeature
  property :name, 'Web-Metabase'
  property :ensure, 'Present'
end

dsc_resource 'IISWMI_Install' do
  resource :windowsfeature
  property :name, 'Web-WMI'
  property :ensure, 'Present'
end

reboot 'Restart Computer' do
  action :nothing
end

dsc_resource 'DNS_Server_Address' do
  resource :xDNSServerAddress
  property :Address, node['configmgr-primary']['dns_ip_address']
  property :InterfaceAlias, node['configmgr-primary']['dns_interface_name']
  property :AddressFamily, node['configmgr-primary']['dns_address_family']
end

dsc_resource 'Join_Domain' do
  resource :xComputer
  property :Name, node['configmgr-primary']['adds_computer_name']
  property :Credential, ps_credential(node['configmgr-primary']['adds_administrator'], node['configmgr-primary']['adds_administrator_password'])
  property :DomainName, node['configmgr-primary']['adds_domain_name']
  notifies :reboot_now, 'reboot[Restart Computer]', :immediately
end

