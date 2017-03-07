#
# Cookbook:: adds-dc
# Recipe:: dc
#
# Copyright:: 2017, The Authors, All Rights Reserved.

reboot 'Restart Computer' do
  action :nothing
end

dsc_resource 'DNS_Server_Address' do
  resource :xDNSServerAddress
  property :Address, node['adds-dc']['dns_ip_address']
  property :InterfaceAlias, node['adds-dc']['dns_interface_name']
  property :AddressFamily, node['adds-dc']['dns_address_family']
end

dsc_resource 'Configure_ADDS' do
  resource :xADDomain
  property :DomainName, node['adds-dc']['adds_domain_name']
  property :DomainAdministratorCredential, ps_credential(node['adds-dc']['adds_administrator'], node['adds-dc']['adds_administrator_password'])
  property :SafemodeAdministratorPassword, ps_credential(node['adds-dc']['adds_administrator_password'])
  property :DomainNetbiosName, node['adds-dc']['adds_domain_netbios']
  notifies :reboot_now, 'reboot[Restart Computer]', :immediately
end

