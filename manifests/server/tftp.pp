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
class razor::server::tftp
(
  $ensure = 'present',

  $undionly_kpxe     = 'undionly.kpxe',
  $undionly_kpxe_url = 'http://boot.ipxe.org/undionly.kpxe',

  $bootstrap_ipxe     = 'bootstrap.ipxe',
  $bootstrap_ipxe_url = 'http://razor:8150/api/microkernel/bootstrap',

  $nic_max = undef,

  # razor::params default values.
  $tmp_dir = $::razor::params::tmp_dir,
)
{
  if ($ensure == 'present' or ensure == present)
  {
    $file_ensure         = 'file'
    $undionly_kpxe_path  = "${tmp_dir}/${undionly_kpxe}"
    $bootstrap_ipxe_path = "${tmp_dir}/${bootstrap_ipxe}"

    # TFTP server.
    contain ::tftp

    # undionly.kpxe
    ::wget::fetch
    { $undionly_kpxe_url:
      destination => $undionly_kpxe_path,
    }

    ::tftp::file
    { $undionly_kpxe:
      ensure  => $file_ensure,
      source  => $undionly_kpxe_path,
      require => ::Wget::Fetch[$undionly_kpxe_url],
    }

    # bootstrap.ipxe
    if ($nic_max != undef)
    {
      validate_integer($nic_max)
      $_bootstrap_ipxe_url = "${bootstrap_ipxe_url}?nic_max=${nic_max}"
    }
    else
    {
      $_bootstrap_ipxe_url = $bootstrap_ipxe_url
    }

    ::wget::fetch
    { $_bootstrap_ipxe_url:
      destination => $bootstrap_ipxe_path,
    }

    if (defined(Class['::razor::server::service']))
    {
      Class['::razor::server::service'] -> ::Wget::Fetch[$_bootstrap_ipxe_url]
    }

    ::tftp::file
    { $bootstrap_ipxe:
      ensure  => $file_ensure,
      source  => $bootstrap_ipxe_path,
      require => ::Wget::Fetch[$_bootstrap_ipxe_url],
    }
  }
}
