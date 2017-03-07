#
# Cookbook:: configmgr-primary
# Recipe:: cm-install
#
# Copyright:: 2017, The Authors, All Rights Reserved.

## Download ConfigMgr installer

configmgr_path_configmgr_install = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\configmgr_install')
configmgr_path_configmgr_install_iso = File.join(configmgr_path_configmgr_install, '\\isos')
configmgr_installer = File.join(configmgr_path_configmgr_install_iso, '\\SC_Configmgr_SCEP_1606.exe')


remote_file configmgr_installer do
  source node['configmgr-primary']['download_source_configmgr']
  action :create
  guard_interpreter :powershell_script
  not_if <<-EOH
    $iso = "#{configmgr_installer}"
    Test-Path $iso
  EOH
end

## Extract ConfigMgr installer

configmgr_path_configmgr_install_folder = File.join(configmgr_path_configmgr_install, '\\SC_Configmgr_SCEP_1606')

directory configmgr_path_configmgr_install_folder do
  inherits true
  action :create
end

seven_zip_archive node['configmgr-primary']['configmgr_binary'] do
  path configmgr_path_configmgr_install_folder
  source configmgr_installer
  overwrite true
  timeout   600
  guard_interpreter :powershell_script
  not_if <<-EOH
    $contents = "#{configmgr_path_configmgr_install_folder}"
    (Get-ChildItem -Path $contents -Recurse).Count -gt 0
  EOH
end

## Download ConfigMgr Prerequisites

configmgr_path_configmgr_prereqs = File.join(configmgr_path_configmgr_install, '\\SC_Configmgr_SCEP_1606_Prereqs')
configmgr_configuration_ini = File.join(configmgr_path_configmgr_install, '\\ConfigMgrUnattend.ini')

directory configmgr_path_configmgr_prereqs do
  inherits true
  action :create
end

cookbook_file configmgr_configuration_ini do
  source 'ConfigMgrUnattend.ini'
  action :create
end

## Install ConfigMgr

configmgr_installer = File.join(configmgr_path_configmgr_install_folder, '\\SMSSETUP\\BIN\\X64\\setup.exe')

windows_package 'System Center Configuration Manager Primary Site Setup' do
  action :install
  source configmgr_installer
  options '/Script #{configmgr_configuration_ini} /NoUserInput'
  installer_type :custom
  timeout 2400
end

