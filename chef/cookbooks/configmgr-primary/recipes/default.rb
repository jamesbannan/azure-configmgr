#
# Cookbook:: configmgr-primary
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'configmgr-primary::storage'
include_recipe 'configmgr-primary::prereqs'
include_recipe 'configmgr-primary::file-structure'
include_recipe 'seven_zip::default'
include_recipe 'configmgr-primary::cm-prereq-install'
include_recipe 'configmgr-primary::cm-install'
