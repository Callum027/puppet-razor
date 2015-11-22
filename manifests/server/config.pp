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
class razor::server::config
(
  $ensure = 'present',

  $dir  = $razor::params::config_dir,
  $file = 'config.yaml',
  $path = undef, # Defined in body

  $owner = 'root',
  $group = 'root',
  $mode  = '0444',
) inherits razor::params
{
  $_path = pick($path, "${dir}/${file}")

  ::concat
  { 'razor::server::config':
    ensure    => $ensure,
    path      => $_path,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    require   => Class['::razor::server::install'],
    subscribe => Class['::razor::server::service'],
  }

  ::concat::fragment
  { 'razor::server::config::header':
    target  => 'razor::server::config',
    order   => '01',
    content => '---\n# This file is managed by Puppet.\n# Any local modifications will be overwritten.\n\n',
  }
}
