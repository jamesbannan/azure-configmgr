
#
# Cookbook:: configmgr-primary
# Recipe:: cm-prereq-install
#
# Copyright:: 2017, The Authors, All Rights Reserved.

## Create the folder structure to house the ADK

configmgr_path_configmgr_install = File.join(node['configmgr-primary']['configmgr_data_folder'], '\\configmgr_install')
configmgr_path_configmgr_install_adk = File.join(configmgr_path_configmgr_install, '\\adk')

directory configmgr_path_configmgr_install_adk do
  inherits true
  action :create
end

## Download the ADK stub installer

adk_installer = File.join(configmgr_path_configmgr_install_adk, '\\adksetup.exe')

remote_file adk_installer do
  source node['configmgr-primary']['download_source_adk']
  action :create
end

## Download the ADK content for an offline installation

powershell_script 'Download_ADK' do
  code <<-EOH
    '#{adk_installer} /quiet /layout #{configmgr_path_configmgr_install_adk}'
  EOH
  timeout 1800
  guard_interpreter :powershell_script
  not_if <<-EOH
    $adkPath = "#{configmgr_path_configmgr_install_adk}"
    (Get-ChildItem $adkPath | Where-Object {$_.Name -eq 'Installers'}).Name -ne $null
  EOH
end

## Install the ADK

windows_package 'Windows Assessment and Deployment Kit - Windows 10' do
  action :install
  source adk_installer
  options node['configmgr-primary']['install_options_adk']
  installer_type :custom
end

## Download SQL Server 2016

configmgr_path_configmgr_install_iso = File.join(configmgr_path_configmgr_install, '\\isos')
configmgr_path_configmgr_install_sql = File.join(configmgr_path_configmgr_install, '\\SQLServer2016')

[
  configmgr_path_configmgr_install_iso,
  configmgr_path_configmgr_install_sql,
].each do |path|
  directory path do
    inherits true
    action :create
  end
end

sql_server_iso = File.join(configmgr_path_configmgr_install_iso, '\\SQLServer2016-x64-ENU.iso')

remote_file sql_server_iso do
  source node['configmgr-primary']['download_source_sql']
  action :create
  guard_interpreter :powershell_script
  not_if <<-EOH
    $iso = "#{sql_server_iso}"
    Test-Path $iso
  EOH
end

## Extract SQL Server 2016

powershell_script 'Mount_Extract_SQL2016_ISO' do
  code <<-EOH
    $mount_params = @{ImagePath = "#{sql_server_iso}"; PassThru = $true; ErrorAction = "Ignore"}
    $mount = Mount-DiskImage @mount_params
      if ($mount)
      {
        $volume = Get-DiskImage -ImagePath $mount.ImagePath | Get-Volume
        $source = $volume.DriveLetter + ":\*"
        $folder = "#{configmgr_path_configmgr_install_sql}"
        $params = @{Path = $source; Destination = $folder; Recurse = $true;}
        exit 0;
      }
      else
      {
        exit 2;
      }
      EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $isoContents = "#{configmgr_path_configmgr_install_sql}"
    (Get-ChildItem -Path $isoContents -Recurse).Count -gt 1
  EOH
end

## Install SQL Server 2016

sql_server_installer = File.join(configmgr_path_configmgr_install_sql, '\\setup.exe')
sql_server_configuration_ini = File.join(configmgr_path_configmgr_install_sql, '\\ConfigurationFile.ini')

cookbook_file sql_server_configuration_ini do
  source 'ConfigurationFile.ini'
  action :create
end

windows_package 'Microsoft SQL Server 2016 (64-bit)' do
  action :install
  source sql_server_installer
  options '/ConfigurationFile=#{sql_server_configuration_ini}'
  installer_type :custom
  timeout 2400
end

powershell_script 'Dismount_SQL2016_ISO' do
  code <<-EOH
    Dismount-DiskImage -ImagePath "#{sql_server_iso}"
  EOH
  guard_interpreter :powershell_script
  only_if <<-EOH
    ((Get-DiskImage -ImagePath "#{sql_server_iso}").Attached) -eq $true
  EOH
end

## Instal SQL Server Management Studio

ssms_installer = File.join(configmgr_path_configmgr_install, '\\SSMS-Setup-ENU.exe')

remote_file ssms_installer do
  source node['configmgr-primary']['download_source_ssms']
  action :create
end

windows_package 'SQL Server 2016 Management Studio' do
  action :install
  source ssms_installer
  options node['configmgr-primary']['install_options_ssms']
  installer_type :custom
end

