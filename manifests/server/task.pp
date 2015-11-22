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
define razor::server::task
(
  # Policy options.
  $boot_sequence,
  $os_version,
  $task_name    = $name,
  $os           = undef,
  $description  = undef,
  $base         = undef,
  $template_dir = undef,

  # Resource options.
  $ensure = 'present',

  # File options.
  $task_path          = 'tasks',
  $task_path_relative = true,

  $metadata_yaml_mode  = '0444',
  $task_directory_mode = '0555',
  $task_path_mode      = '0555',

  # razor::params default values.
  $razor_user      = $::razor::params::razor_user,
  $razor_group     = $::razor::params::razor_group,
  $server_data_dir = $::razor::params::server_data_dir,
)
{
  if ($ensure == 'present' or $ensure == present)
  {
    $directory_ensure = 'directory'
    $file_ensure      = 'file'
  }
  else
  {
    $directory_ensure = $ensure
    $file_ensure      = $ensure
  }

  if ($task_path_relative == true)
  {
    $task_path_full = "${server_data_dir}/${task_path}"
  }
  else
  {
    $task_path_full = $task_path
  }

  # Create the task directory, and copy the task templates into it.
  if (!(defined(File[$task_path_full])))
  {
    file
    { $task_path_full:
      ensure  => $directory_ensure,
      owner   => $razor_user,
      group   => $razor_group,
      mode    => $task_path_mode,
    }
  }

  Class['::razor::server::service'] -> File[$task_path_full]

  file
  { "${task_path_full}/${task_name}.task":
    ensure  => $directory_ensure,
    owner   => $razor_user,
    group   => $razor_group,
    mode    => $task_directory_mode,
    recurse => 'remote',
    source  => $template_dir,
    require => Class['::razor::server::service'],
  }

  # The metadata file for this task.
  file
  { "${task_path_full}/${task_name}.task/metadata.yaml":
    ensure  => $file_ensure,
    owner   => $razor_user,
    group   => $razor_group,
    mode    => $metadata_yaml_mode,
    content => template('razor/metadata.yaml.erb'),
    require => Class['::razor::server::service'],
  }
}
