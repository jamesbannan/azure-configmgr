
default['configmgr-primary']['storage_pool_friendly_name'] = 'ConfigMgrStoragePool'
default['configmgr-primary']['virtual_disk_friendly_name'] = 'ConfigMgrData'
default['configmgr-primary']['virtual_disk_resiliency'] = 'Simple'
default['configmgr-primary']['volume_friendly_name'] = 'ConfigMgr'
default['configmgr-primary']['volume_file_system'] = 'NTFS'
default['configmgr-primary']['volume_drive_letter'] = 'M'

default['configmgr-primary']['nuget_modules'] = '("xActiveDirectory","xNetworking","xSQlPs","xSQLServer","xComputerManagement")'

default['configmgr-primary']['dns_ip_address'] = ['10.10.1.4']
default['configmgr-primary']['dns_interface_name'] = 'Ethernet 2'
default['configmgr-primary']['dns_address_family'] = 'IPv4'

default['configmgr-primary']['adds_computer_name'] = 'cm-01'
default['configmgr-primary']['adds_domain_name'] = 'corp.sccmlab.net'
default['configmgr-primary']['adds_administrator'] = 'SCCMLAB\\lab-admin'
default['configmgr-primary']['adds_administrator_password'] = 'P@ssw0rd'

default['configmgr-primary']['configmgr_data_folder'] = 'M:\\resources'
default['configmgr-primary']['configmgr_share_name'] = 'resources'

default['configmgr-primary']['download_source_adk'] = 'https://go.microsoft.com/fwlink/p/?LinkId=526740'
default['configmgr-primary']['download_source_sql'] = 'http://care.dlservice.microsoft.com/dl/download/F/E/9/FE9397FA-BFAB-4ADD-8B97-91234BC774B2/SQLServer2016-x64-ENU.iso'
default['configmgr-primary']['download_source_ssms']  = 'https://go.microsoft.com/fwlink/?LinkID=840946'
default['configmgr-primary']['install_options_adk'] = '/Features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.UserStateMigrationTool /norestart /quiet /ceip off'
default['configmgr-primary']['install_options_ssms'] = '/install /quiet /norestart'

default['configmgr-primary']['configmgr_binary'] = 'SC_Configmgr_SCEP_1606.exe'
default['configmgr-primary']['download_source_configmgr'] = 'http://care.dlservice.microsoft.com/dl/download/F/B/9/FB9B10A3-4517-4E03-87E6-8949551BC313/SC_Configmgr_SCEP_1606.exe'
