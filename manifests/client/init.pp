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
	$ensure	= "present",

	$razor_client_packages	= $razor::params::razor_client_packages
) inherits razor::params
{
	if ($ensure == "present")
	{
		$package_ensure = "installed"
	}
	else
	{
		$package_ensure = $ensure
	}

	# TODO: Make sure a 1.9.3-compatible Ruby instance is installed.
	# Either MRI Ruby >= 1.9.3 or JRuby (MRI Ruby preferred).

	package
	{ $razor_client_packages:
		ensure		=> $package_ensure,
		provider	=> gem,
	}
}
