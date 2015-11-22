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
class razor::server::microkernel
(
  $ensure = 'present',

  $source = 'http://links.puppetlabs.com/razor-microkernel-latest.tar',
  $file   = 'microkernel.tar',
  $dir    = 'microkernel',

  $repo_store_root         = undef, # Defined in body
  $collect_repo_store_root = true,

  $initrd_mode          = '0555',
  $repo_store_root_mode = '0555',
  $vmlinuz_mode         = '0555',

  # razor::params default values.
  $razor_user  = $::razor::params::razor_user,
  $razor_group = $::razor::params::razor_group,
  $tmp_dir     = $::razor::params::tmp_dir,
) inherits razor::params
{
  if ($repo_store_root == undef and defined(Class['::razor::server::config::default']))
  {
    $_repo_store_root = $::razor::server::config::default::_repo_store_root
  }
  else
  {
     $_repo_store_root = $repo_store_root
  }

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

  include ::archive

  # Download and extract the latest Razor microkernel.
  archive
  { "${tmp_dir}/${file}":
    ensure       => $ensure,

    source       => $source,

    extract      => true,
    extract_path => $tmp_dir,

    creates      => "${tmp_dir}/${dir}",
  }

  # Place the initial ramdisk and kernel images in the correct location.
  if (!(defined(File[$_repo_store_root])))
  {
    file
    { $_repo_store_root:
      ensure => $directory_ensure,
      owner  => $razor_user,
      group  => $razor_group,
      mode   => $repo_store_root_mode,
    }
  }

  file
  { "${_repo_store_root}/initrd0.img":
    ensure  => $file_ensure,
    source  => "${tmp_dir}/${dir}/initrd0.img",

    owner   => $razor_user,
    group   => $razor_group,
    mode    => $initrd_mode,

    require => [Archive["${tmp_dir}/${file}"], Class['::razor::server::service']],
  }

  file
  { "${_repo_store_root}/vmlinuz0":
    ensure  => $file_ensure,
    source  => "${tmp_dir}/${dir}/vmlinuz0",

    owner   => $razor_user,
    group   => $razor_group,
    mode    => $vmlinuz_mode,

    require => [Archive["${tmp_dir}/${file}"], Class['::razor::server::service']],
  }
}
