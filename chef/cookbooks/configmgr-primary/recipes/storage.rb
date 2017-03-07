#
# Cookbook:: .
# Recipe:: storage
#
# Copyright:: 2017, The Authors, All Rights Reserved.

dsc_resource 'File-Server' do
  resource :windowsfeature
  property :name, 'FS-FileServer'
  property :ensure, 'Present'
end

powershell_script 'Create Storage Pool' do
  code <<-EOH
    $storagePoolFriendlyName = "#{node['configmgr-primary']['storage_pool_friendly_name']}"
    $primordialDisks = Get-StorageSubSystem -FriendlyName 'Windows Storage*' | Get-PhysicalDisk -CanPool $True
    New-StoragePool -FriendlyName $storagePoolFriendlyName -StorageSubsystemFriendlyName 'Windows Storage*' -PhysicalDisks $primordialDisks
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $storagePoolFriendlyName = "#{node['configmgr-primary']['storage_pool_friendly_name']}"
    (Get-StoragePool | Where-Object {$_.FriendlyName -eq $storagePoolFriendlyName}).FriendlyName -ne $null
  EOH
end

powershell_script 'Create Virtual Disk' do
  code <<-EOH
    $storagePoolFriendlyName = "#{node['configmgr-primary']['storage_pool_friendly_name']}"
    $virtualDiskFriendlyName = "#{node['configmgr-primary']['virtual_disk_friendly_name']}"
    $virtualDiskResiliency = "#{node['configmgr-primary']['virtual_disk_resiliency']}"
    New-VirtualDisk -StoragePoolFriendlyName $storagePoolFriendlyName -FriendlyName $virtualDiskFriendlyName -ResiliencySettingName $virtualDiskResiliency -UseMaximumSize | Initialize-Disk
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $virtualDiskFriendlyName = "#{node['configmgr-primary']['virtual_disk_friendly_name']}"
    (Get-VirtualDisk | Where-Object {$_.FriendlyName -eq $virtualDiskFriendlyName}).FriendlyName -ne $null
  EOH
end

powershell_script 'Create Volume' do
  code <<-EOH
    $virtualDiskFriendlyName = "#{node['configmgr-primary']['virtual_disk_friendly_name']}"
    $volumeFriendlyName = "#{node['configmgr-primary']['volume_friendly_name']}"
    $volumeFileSystem = "#{node['configmgr-primary']['volume_file_system']}"
    $volumeDriveLetter = "#{node['configmgr-primary']['volume_drive_letter']}"
    $disk = Get-Disk -FriendlyName $virtualDiskFriendlyName
    New-Volume -DiskUniqueId $disk.UniqueId -FriendlyName $volumeFriendlyName -FileSystem $volumeFileSystem -DriveLetter $volumeDriveLetter
  EOH
  guard_interpreter :powershell_script
  not_if <<-EOH
    $volumeFriendlyName = "#{node['configmgr-primary']['volume_friendly_name']}"
    (Get-Volume | Where-Object {$_.FileSystemLabel -eq $volumeFriendlyName}).FileSystemLabel -ne $null
  EOH
end

