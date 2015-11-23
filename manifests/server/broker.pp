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
define razor::server::broker
(
  $broker_type,
  $broker_name   = $name,
  $configuration = undef,

  $ensure = 'present',
  $args   = undef, # Defined in body

  # razor::params default values.
  $client_url = $::razor::params::client_url,
  $razor      = $::razor::params::razor,
)
{
  if ($args != undef)
  {
    $_args = $args
  }
  elsif ($configuration != undef)
  {
    $_args = "--configuration '${configuration}'"
  }
  else
  {
    $_args = ''
  }

  if ($ensure == 'present' or $ensure == present)
  {
    exec
    { "razor::server::broker::create::${name}":
      command => "${razor} --url ${client_url} create-broker ${_args} --name ${broker_name} --broker-type ${broker_type}",
      unless  => "${razor} --url ${client_url} brokers ${broker_name}",
      require => Class['::razor::server::service'],
    }
  }
  elsif ($ensure == 'absent' or $ensure == absent)
  {
    exec
    { "razor::server::broker::delete::${name}":
      command => "${razor} --url ${client_url} delete-broker --name ${broker_name}",
      onlyif  => "${razor} --url ${client_url} brokers ${broker_name}",
      require => Class['::razor::server::service'],
    }
  }
}
