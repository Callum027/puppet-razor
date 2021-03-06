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
define razor::server::policy
(
  # Required policy options.
  $hostname,
  $root_password,
  $repo,
  $broker,
  $policy_name = $name,

  # Optional policy options.
  $enabled       = undef,
  $max_count     = undef,
  $before        = undef,
  $after         = undef,
  $tags          = undef,
  $task          = undef,
  $node_metadata = undef,

  # Dependency options, if optional arguments are set.
  $require_repo   = true,
  $require_broker = true,
  $require_tags   = true,

  $ensure   = 'present',
  $tmp_file = undef, # Defined in body

  # razor::params default values.
  $client_url = $::razor::params::client_url,
  $razor      = $::razor::params::razor,
  $rm         = $::razor::params::rm,
  $tmp_dir    = $::razor::params::tmp_dir,
)
{
  validate_string($policy_name, $hostname, $root_password)

  if ($before != undef and $after != undef)
  {
    fail("only one of before and after are allowed to be specified")
  }

  $_tmp_file = pick($tmp_file, "${tmp_dir}/razor_policy_${name}.json")

  if ($ensure == 'present' or $ensure == present)
  {
    $file_ensure = 'file'
  }
  else
  {
    $file_ensure = $ensure
  }

  file
  { "razor::server::policy::tmp_file::${name}":
    ensure  => $file_ensure,
    path    => $_tmp_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('razor/policy.json.erb'),
  }

  if ($ensure == 'present' or $ensure == present)
  {
    exec
    { "razor::server::policy::create::${name}":
      command => "${razor} --url ${client_url} create-policy --json ${_tmp_file}",
      unless  => "${razor} --url ${client_url} policies ${policy_name}",
      require => [Class['::razor::server::service'], File["razor::server::policy::tmp_file::${name}"]],
    }

    if ($require_repo == true)
    {
      ::Razor::Server::Repo[$repo] -> Exec["razor::server::policy::create::${name}"]
    }

    if ($require_broker == true)
    {
      ::Razor::Server::Broker[$broker] -> Exec["razor::server::policy::create::${name}"]
    }

    if ($tags != undef and $require_tags == true)
    {
      ::Razor::Server::Tag[$tags] -> Exec["razor::server::policy::create::${name}"]
    }
  }
  elsif ($ensure == 'absent' or $ensure == absent)
  {
    exec
    { "razor::server::policy::delete::${name}":
      command => "${razor} --url ${client_url} delete-policy --name ${policy_name}",
      onlyif  => "${razor} --url ${client_url} policies ${policy_name}",
      require => Class['::razor::server::service'],
    }
  }
}
