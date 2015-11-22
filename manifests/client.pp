# == Class: huttradio::clients::razor
#
# Puppet Razor client installation.
#
# === Parameters
#
# === Variables
#
# === Examples
#
# Put this into your node in site.pp:
# include huttradio::clients::krb5_client
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2014 Callum Dickinson.
#
class razor::client
(
  $ensure          = 'present',
  $client_packages = $::razor::params::client_packages,
) inherits razor::params
{
  require ::razor::params

  if ($ensure == 'present' or $ensure == present)
  {
    $package_ensure = 'installed'
  }
  else
  {
    $package_ensure = $ensure
  }

  package
  { $client_packages:
    ensure   => $package_ensure,
    provider => 'gem',
  }
}
