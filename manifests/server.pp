# == Class: koha::repo
#
# Set up the Koha APT repository.
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
#  class { koha:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2015 Callum Dickinson.
#
class razor::server
(
  $ensure              = 'present',
  $install_postgresql  = true,
  $install_microkernel = true,
)
{
  # Install the repository and client packages, required on the server.
  if (!(defined(Class['::razor::repo'])))
  {
    class
    { '::razor::repo':
      ensure => $ensure,
    }
  }

  if (!(defined(Class['::razor::client'])))
  {
    class
    { '::razor::client':
      ensure => $ensure,
    }
  }

  # Install and start the Razor Server.
  if (!(defined(Class['::razor::server::install'])))
  {
    class
    { '::razor::server::install':
      ensure    => $ensure,
    }
  }

  if (!(defined(Class['::razor::server::service'])))
  {
    class
    { '::razor::server::service':
      ensure => $ensure,
    }
  }

  # Install the PostgreSQL database automatically, if enabled.
  if ($install_postgresql == true)
  {
    class
    { '::razor::server::postgresql':
      ensure => $ensure,
    }
  }

  # Install the microkernel necessary for booting nodes via PXE/TFTP automatically, if enabled.
  if ($install_microkernel == true)
  {
    class
    { '::razor::server::microkernel':
      ensure => $ensure,
    }
  }
}
