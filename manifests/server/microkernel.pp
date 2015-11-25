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
define razor::server::microkernel
(
  $environment = $name,
  $ensure      = 'present',

  # Public arguments.
  $source               = $microkernel_source,
  $repo_store_root      = undef, # Defined in body
  $repo_microkernel_dir = 'microkernel',

  # Private arguments.

  $file   = 'microkernel.tar',
  $dir    = 'microkernel',

  $initrd_owner = $::razor::params::razor_user,
  $initrd_group = $::razor::params::razor_group,
  $initrd_mode  = '0555',

  $vmlinuz_owner = $::razor::params::razor_user,
  $vmlinuz_group = $::razor::params::razor_group,
  $vmlinuz_mode  = '0555',

  # razor::params default values.
  $tmp_dir = $::razor::params::tmp_dir,
)
{
  $_repo_store_root = pick_default($repo_store_root, getparam(::Razor::Server::Config::Environment[$environment], 'repo_store_root'))

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

  # Download and extract the latest Razor microkernel.
  include ::archive

  archive
  { "${_repo_store_root}/razor-microkernel-${name}-${file}":
    ensure       => $ensure,
    source       => $source,

    extract      => true,
    extract_path => $tmp_dir,

    creates      => "${_repo_store_root}/${dir}",
    cleanup      => true,
  }

  # Place the initial ramdisk and kernel images in the correct location.
  file
  { "${_repo_store_root}/${repo_microkernel_dir}/initrd0.img":
    ensure  => $file_ensure,

    owner   => $initrd_user,
    group   => $initrd_group,
    mode    => $initrd_mode,

    require => Archive["${_repo_store_root}/${file}"],
  }

  file
  { "${_repo_store_root}/${repo_microkernel_dir}/vmlinuz0":
    ensure  => $file_ensure,

    owner   => $vmlinuz_user,
    group   => $vmlinuz_group,
    mode    => $vmlinuz_mode,

    require => Archive["${_repo_store_root}/${file}"],
  }
}
