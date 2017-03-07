#
# Cookbook:: configmgr-primary
# Recipe:: file-structure
#
# Copyright:: 2017, The Authors, All Rights Reserved.

directory node['configmgr-primary']['configmgr_data_folder'] do
  inherits true
  action :create
end

powershell_script 'Create_Share_Resources' do
  code <<-EOH
    $shareName = "#{node['configmgr-primary']['configmgr_share_name']}"
    New-SmbShare -Name $shareName -Path "#{node['configmgr-primary']['configmgr_data_folder']}" -FullAccess 'Everyone' -CachingMode None
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $shareName = "#{node['configmgr-primary']['configmgr_share_name']}"
    (Get-SmbShare | Where-Object {$_.Name -eq $shareName}).Name -ne $null
  EOH
end

configmgr_path_software = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\software')
configmgr_path_osd = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\osd')
configmgr_path_driver_sources = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\driver_sources')
configmgr_path_driver_packages = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\driver_packages')
configmgr_path_update_packages = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\update_packages')
configmgr_path_configmgr_install = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\configmgr_install')

[
  configmgr_path_software,
  configmgr_path_osd,
  configmgr_path_driver_sources,
  configmgr_path_driver_packages,
  configmgr_path_update_packages,
  configmgr_path_configmgr_install,
].each do |path|
  directory path do
    inherits true
    action :create
  end
end
