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
define razor::server::config::environment
(
  $ensure           = 'present',
  $environment_name = $name,

  $database_url        = undef,
  $auth                = undef,
  $microkernel         = undef,
  $secure_api          = undef,
  $protect_new_nodes   = undef,
  $store_hook_input    = undef,
  $store_hook_output   = undef,
  $match_nodes_on      = undef,
  $checkin_interval    = undef,
  $task_path           = undef,
  $repo_store_root     = undef,
  $broker_path         = undef,
  $hook_path           = undef,
  $hook_execution_path = undef,
  $facts               = undef,

  $create_repo_store_root = true,
  $repo_store_root_owner  = $::razor::params::razor_user,
  $repo_store_root_group  = $::razor::params::razor_group,
  $repo_store_root_mode   = '0755',
)
{
  # Validate all arguments (as much as we can, anyway.)
  validate_string($environment_name)

  if ($database_url != undef)
  {
    validate_re($database_url, '^jdbc:postgresql:.*', "Invalid JDBC PostgreSQL URL specified: ${database_url}")
  }

  if ($auth != undef)
  {
    validate_hash($auth)
  }

  if ($microkernel != undef)
  {
    validate_hash($microkernel)
  }

  if ($secure_api != undef)
  {
    validate_bool($secure_api)
  }

  if ($protect_new_nodes != undef)
  {
    validate_bool($protect_new_nodes)
  }

  if ($store_hook_input != undef)
  {
    validate_bool($store_hook_input)
  }

  if ($store_hook_output != undef)
  {
    validate_bool($store_hook_output)
  }

  if ($match_nodes_on != undef)
  {
    validate_array($match_nodes_on)
  }

  if ($checkin_interval != undef)
  {
    validate_integer($checkin_interval)
  }

  if ($task_path != undef)
  {
    validate_array($task_path)
    $_task_path = join($task_path, ':')
  }

  if ($repo_store_root != undef)
  {
    validate_absolute_path($repo_store_root)
  }

  if ($broker_path != undef)
  {
    validate_array($broker_path)
    $_broker_path = join($broker_path, ':')
  }

  if ($hook_path != undef)
  {
    validate_array($hook_path)
    $_hook_path = join($hook_path, ':')
  }

  if ($hook_execution_path != undef)
  {
    validate_array($hook_execution_path)
    $_hook_execution_path = join($hook_execution_path, ':')
  }

  if ($facts != undef)
  {
    validate_hash($facts)
  }

  # Create any file resources configured.
  if ($ensure == 'present' or $ensure == present)
  {
    $directory_ensure = 'directory'
  }

  if ($create_repo_store_root == true and !(defined(File[$repo_store_root])))
  {
    file
    { $repo_store_root:
      ensure => $directory_ensure,
      owner  => $repo_store_root_owner,
      group  => $repo_store_root_group,
      mode   => $repo_store_root_mode,
    }
  }

  # Add the environment to config.yaml.
  concat::fragment
  { "razor::server::config::environment::${name}":
    target  => 'razor::server::config',
    order   => '02',
    content => template('razor/config.yaml.environment.erb'),
  }
}
