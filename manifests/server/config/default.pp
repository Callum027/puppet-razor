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
class razor::server::config::default
(
  $ensure            = 'present',

  $database_url     = undef, # Defined in body
  $collect_database = true,

  $auth_enabled = false,
  $auth_config  = 'shiro.ini',

  $microkernel_debug_level   = 'debug',
  $microkernel_kernel_args   = undef,
  $microkernel_extension_zip = undef,

  $secure_api        = false,
  $protect_new_nodes = false,
  $store_hook_input  = false,
  $store_hook_output = false,

  $match_nodes_on = ['mac'],

  $checkin_interval = 15,

  $task_path = ['tasks'],

  $repo_store_root = undef, # Defined in body

  $broker_path         = ['brokers'],
  $hook_path           = ['hooks'],
  $hook_execution_path = undef,

  $facts_blacklist =
  [
    'domain',
    'filesystems',
    'fqdn',
    'hostname',
    'id',
    '/kernel.*/',
    'memoryfree',
    'memorysize',
    'memorytotal',
    '/operatingsystem.*/',
    'osfamily',
    'path',
    'ps',
    'rubysitedir',
    'rubyversion',
    'selinux',
    'sshdsakey',
    '/sshfp_[dr]sa/',
    'sshrsakey',
    '/swap.*/',
    'timezone',
    '/uptime.*/'
  ],

  $facts_match_on = undef,

  # razor::params default values.
  $server_data_dir = $::razor::params::server_data_dir,
) inherits razor::params
{
  # Default post-processed values.
  $_repo_store_root = pick($repo_store_root, "${server_data_dir}/repo-store")

  if ($auth_enabled != undef and $auth_config != undef)
  {
    $_auth = {'enabled' => $auth_enabled, 'config'  => $auth_config}
  }
  elsif ($auth_enabled != undef)
  {
    $_auth = {'enabled' => $auth_enabled, 'config'  => $auth_config}
  }
  elsif ($auth_config != undef)
  {
    $_auth = {'enabled' => $auth_enabled, 'config'  => $auth_config}
  }

  if ($microkernel_debug_level != undef and $facts_kernel_args != undef and $microkernel_extension_zip != undef)
  {
    $_microkernel =
    {
      'debug_level'   => $microkernel_debug_level,
      'kernel_args'   => $microkernel_kernel_args,
      'extension-zip' => $microkernel_extension_zip,
    }
  }
  elsif ($microkernel_debug_level != undef and $facts_kernel_args != undef)
  {
    $_microkernel =
    {
      'debug_level' => $microkernel_debug_level,
      'kernel_args' => $microkernel_kernel_args,
    }
  }
  elsif ($facts_kernel_args != undef and $microkernel_extension_zip != undef)
  {
    $_microkernel =
    {
      'kernel_args'   => $microkernel_kernel_args,
      'extension-zip' => $microkernel_extension_zip,
    }
  }
  elsif ($microkernel_debug_level != undef)
  {
    $_microkernel = {'debug_level' => $microkernel_debug_level}
  }
  elsif ($facts_kernel_args != undef)
  {
    $_microkernel = {'kernel_args' => $microkernel_kernel_args}
  }
  elsif ($microkernel_extension_zip != undef)
  {
    $_microkernel = {'extension-zip' => $microkernel_extension_zip}
  }

  if ($facts_blacklist != undef and $facts_match_on != undef)
  {
    $_facts = {'blacklist' => $facts_blacklist, 'match_on'  => $facts_match_on}
  }
  elsif ($facts_blacklist != undef)
  {
    $_facts = {'blacklist' => $facts_blacklist, 'match_on'  => $facts_match_on}
  }
  elsif ($facts_match_on != undef)
  {
    $_facts = {'blacklist' => $facts_blacklist, 'match_on'  => $facts_match_on}
  }

  # Collect the database information from a local or remote PostgreSQL database, or the parameter.
  if ($database_url == undef and $collect_database == true)
  {
    if (defined(Class['::razor::server::postgresql']))
    {
      $_database_url = "jdbc:postgresql:${::razor::server::postgresql::db}?user=${::razor::server::postgresql::user}&password=${::razor::server::postgresql::password}"
    }
    else
    {
      $postgresql_hostname = join(values_at(query_nodes('Class["razor::server::postgresql"]'), 0), ',')

      ::Razor::Server::Postgresql::Export <<| hostname == $postgresql_hostname |>>

      $postgresql_db       = getparam(::Razor::Postgresql::Export[$postgresql_hostname], "db")
      $postgresql_user     = getparam(::Razor::Postgresql::Export[$postgresql_hostname], "user")
      $postgresql_password = getparam(::Razor::Postgresql::Export[$postgresql_hostname], "password")

      $_database_url = "jdbc:postgresql://${postgresql_hostname}/${postgresql_db}?user=${postgresql_user}&password=${postgresql_password}"
    }
  }
  else
  {
    $_database_url = $database_url
  }

  # Make sure that the configuration file is defined.
  if (!(defined(Class['::razor::server::config'])))
  {
    class
    { '::razor::server::config':
      ensure => $ensure,
    }
  }

  # One environment, 'all', with everything.
  ::razor::server::config::environment
  { 'all':
    ensure              => $ensure,

    database_url        => $_database_url,

    auth                => $_auth,

    microkernel         => $_microkernel,

    secure_api          => $secure_api,
    protect_new_nodes   => $protect_new_nodes,
    store_hook_input    => $store_hook_input,
    store_hook_output   => $store_hook_output,

    match_nodes_on      => $match_nodes_on,

    checkin_interval    => $checkin_interval,

    task_path           => $task_path,

    repo_store_root     => $_repo_store_root,

    broker_path         => $broker_path,
    hook_path           => $hook_path,
    hook_execution_path => $hook_execution_path,

    facts               => $_facts,
  }
}
