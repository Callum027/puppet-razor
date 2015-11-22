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
class razor::repo($ensure = 'present')
{
  # Prepare the package manager with the Koha repository.
  case $::osfamily
  {
    'Debian':
    {
      apt::source
      { 'puppetlabs':
        ensure   => $ensure,
        location => 'http://apt.puppetlabs.com',
        repos    => 'main dependencies',
        key      =>
        {
          'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
          'server' => 'pgp.mit.edu',
        },
      }
    }

    # RedHat support will come at a later time!

    default:
    {
      fail("Sorry, but this module does not support the ${::osfamily} OS family at this time")
    }
  }

  if ($ensure != 'present' and $ensure != 'absent')
  {
    fail("invalid value for ensure: ${ensure}")
  }
}
