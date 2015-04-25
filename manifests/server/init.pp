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
class razor::server
(
	$ensure	= "present"
)
	if (Class["razor::client"] == undef)
	{
		class
		{ "razor::client":
			ensure	=> $ensure,
		}
	}
{
	if (Class["razor::server::install"] == undef)
	{
		class
		{ "razor::server::install":
			ensure	=> $ensure,
		}
	}

	if (Class["razor::server::postgresql"] == undef)
	{
		class
		{ "razor::server::postgresql":
			ensure	=> $ensure,
		}
	}

	if (Class["razor::server::config"] == undef)
	{
		class
		{ "razor::server::config":
			ensure	=> $ensure,
		}
	}

	if (Class["razor::server::microkernel"] == undef)
	{
		class
		{ "razor::server::microkernel":
			ensure	=> $ensure,
		}
	}

	if ($ensure = "present")
	{
		service
		{ $razor_server_services:
			ensure	=> "running",
			require	=> [Class["razor::server::install"], Class["razor::server::postgresql"], Class["razor::server::config"]]
		}
	}
}
