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
define razor::server::hook
(
  $hook_type,
  $configuration,
  $hook_name = $name,

  $ensure = 'present',

  # razor::params default values.
  $grep  = $::razor::params::grep,
  $razor = $::razor::params::razor,
)
{
  $configuration_args = join($configuration, " --configuration ")

  if ($ensure == 'present')
  {
    exec
    { "razor::server::hook::create::${name}":
      command => "${razor} create-hook --name ${hook_name} --hook-type ${hook_type} --configuration ${configuration_args}",
      unless  => "${razor} hooks | ${grep} '^| ${repo_name} |'",
      require => Class['::razor::server::service'],
    }

    exec
    { "razor::server::hook::update_configuration::${name}":
      command => "${razor} update-hook-configuration --name ${hook_name} --hook-type ${hook_type} --configuration ${configuration_args}",
      unless  => "${razor} hooks | ${grep} '^| ${repo_name} |'",
      require => Class['::razor::server::service'],
    }
  }
  elsif ($ensure == 'absent')
  {
    exec
    { 'razor::server::hook::delete':
      command => "${razor} delete-hook --name ${hook_name}",
      onlyif  => "${razor} hook | ${grep} '^| ${hook_name} |'",
      require => Class['::razor::server::service'],
    }
  }
}
