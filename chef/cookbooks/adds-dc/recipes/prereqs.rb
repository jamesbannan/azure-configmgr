#
# Cookbook:: adds-dc
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
    $modules = [array]@#{node['adds-dc']['nuget_modules']}
    foreach($module in $modules){Install-Module -Name $module -Force | Import-Module}
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $modules = [array]@#{node['adds-dc']['nuget_modules']}
    $modulePath = "#{ps_module_path}"
    foreach($module in $modules){(Get-ChildItem $modulePath | Where-Object {$_.Name -eq $module}).Name -ne $null}
  EOH
end

dsc_resource 'DNS_Install' do
  resource :windowsfeature
  property :name, 'DNS'
  property :ensure, 'Present'
end

dsc_resource 'ADDS_Install' do
  resource :windowsfeature
  property :name, 'AD-Domain-Services'
  property :ensure, 'Present'
end

dsc_resource 'RSAT_AD_AdminCenter_Install' do
  resource :windowsfeature
  property :name, 'RSAT-AD-AdminCenter'
  property :ensure, 'Present'
end

dsc_resource 'RSAT_ADDS_Install' do
  resource :windowsfeature
  property :name, 'RSAT-ADDS'
  property :ensure, 'Present'
end

dsc_resource 'RSAT_AD_PowerShell_Install' do
  resource :windowsfeature
  property :name, 'RSAT-AD-PowerShell'
  property :ensure, 'Present'
end

dsc_resource 'RSAT_AD_Tools_Install' do
  resource :windowsfeature
  property :name, 'RSAT-AD-Tools'
  property :ensure, 'Present'
end

dsc_resource 'RSAT_Role_Tools_Install' do
  resource :windowsfeature
  property :name, 'RSAT-Role-Tools'
  property :ensure, 'Present'
end
