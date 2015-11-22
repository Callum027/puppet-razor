# == Class: razor
#
# Full description of class razor here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'razor':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class razor::server::directories
(
  $ensure = 'present',

  $repo_store_root       = $::razor::server::config::default::_repo_store_root,
  $repo_store_root_owner = $::razor::params::razor_user,
  $repo_store_root_group = $::razor::params::razor_group,
  $repo_store_root_mode  = '0755',
) inherits razor::params
{
  if ($ensure == 'present' or ensure == present)
  {
    $directory_ensure = 'directory'
    $file_ensure = 'file'
  }
  else
  {
    $directory_ensure = $ensure
    $file_ensure = $ensure
  }

  file
  { $repo_store_root:
    ensure => $directory_ensure,
    owner  => $repo_store_root_owner,
    group  => $repo_store_root_group,
    mode   => $repo_store_root_mode,
  }
}
