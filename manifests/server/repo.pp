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
define razor::server::repo
(
  $task,
  $repo_name = $name,
  $url       = undef,
  $iso_url   = undef,

  $archive_url     = undef,
  $archive_root    = undef,
  $archive_creates = undef,

  $environment     = 'all',
  $repo_store_root = undef, # Defined in body

  $ensure = 'present',
  $args   = undef, # Defined in body

  # razor::params default values.
  $tmp_dir         = $::razor::params::tmp_dir,
  $client_url      = $::razor::params::client_url,
  $razor           = $::razor::params::razor,
)
{
  if ($args != undef)
  {
    $_args = $args
  }
  elsif ($iso_url != undef)
  {
    $_args = "--iso-url ${iso_url}"
  }
  elsif ($url != undef)
  {
    $_args = "--url ${url}"
  }
  else
  {
    $_args = '--no-content true'
  }

  if ($ensure == 'present' or $ensure == present)
  {
    exec
    { "razor::server::repo::${name}":
      command => "${razor} --url ${client_url} create-repo ${_args} --name ${repo_name} --task ${task}",
      unless  => "${razor} --url ${client_url} repos ${repo_name}",
      require => Class['::razor::server::service'],
    }
  }
  elsif ($ensure == 'absent' or $ensure == absent)
  {
    exec
    { "razor::server::repo::${name}":
      command => "${razor} --url ${client_url} delete-repo --name ${repo_name}",
      onlyif  => "${razor} --url ${client_url} repos ${repo_name}",
      require => Class['::razor::server::service'],
    }
  }

  if ($url == undef and $iso_url == undef and $archive_url != undef)
  {
    $archive_basename = basename($archive_url)
    $_repo_store_root = pick_default($repo_store_root, getparam(::Razor::Server::Config::Environment[$environment], 'repo_store_root'))

    if ($archive_root != undef)
    {
      $extract_path = "${_repo_store_root}/${repo_name}${archive_root}"
      $archive_dirtree  = prefix(dirtree($archive_root), "${_repo_store_root}/${repo_name}")

      if ($ensure == 'present' or $ensure == present)
      {
        $directory_ensure = 'directory'
      }
      else
      {
        $directory_ensure = $ensure
      }

      file
      { "${_repo_store_root}/${repo_name}":
        ensure  => $directory_ensure,
        require => Exec["razor::server::repo::${name}"],
        before  => Archive["${tmp_dir}/razor-repo-${name}-${archive_basename}"],
      }

      file
      { $archive_dirtree:
        ensure  => $directory_ensure,
        require => Exec["razor::server::repo::${name}"],
        before  => Archive["${tmp_dir}/razor-repo-${name}-${archive_basename}"],
      }
    }
    else
    {
      $extract_path = "${_repo_store_root}/${repo_name}"
    }

    if ($archive_creates != undef)
    {
      $extract_creates = "${extract_path}${archive_creates}"
    }

    archive
    { "${tmp_dir}/razor-repo-${name}-${archive_basename}":
      ensure       => $ensure,
      source       => $archive_url,

      extract      => true,
      extract_path => $extract_path,
      creates      => $extract_creates,

      cleanup      => true,
    }
  }
}
