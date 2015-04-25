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
define razor::server::broker
(
	$ensure		= "present",

	$broker_name	= $name,
	$broker_type,

	$configuration	= undef,

	$grep		= undef,
	$razor		= undef,
	$rm		= undef,

	$tmp_dir	= undef
)
{
	require razor::params

	if ($grep == undef)
	{
		$razor = $razor::params::grep
	}

	if ($razor == undef)
	{
		$razor = $razor::params::razor
	}

	if ($rm == undef)
	{
		$rm = $razor::params::rm
	}

	if ($tmp_dir == undef)
	{
		$tmp_dir = $razor::params::tmp_dir
	}

	if ($ensure == "present")
	{
		file
		{ "$tmp_dir/razor-server-broker-create.sh":
			owner	=> root,
			group	=> root,
			mode	=> 755,
			content	=> template("razor/razor-server-broker-create.sh.erb"),
		}

		exec
		{ "razor::server::broker:create":
			command	=> "$tmp_dir/razor-server-broker-create.sh",
			unless	=> "$razor brokers | $grep '^| $broker_name |'",
			require	=>
			[
				Class[ [ "razor::client", "razor::install", "razor::postgresql", "razor::config", "razor::microkernel" ] ],
				File["$tmp_dir/razor-server-broker-create.sh"]
			],
		}
	}
	elsif ($ensure == "absent")
	{
		file
		{ "$tmp_dir/razor-server-broker-create.sh":
			ensure	=> $ensure,
		}

		exec
		{ "razor::server::broker::delete":
			command	=> "$razor delete-broker --name $broker_name",
			onlyif	=> "$razor broker | $grep '^| $broker_name |'",
			require	=> Class[ [ "razor::client", "razor::install", "razor::postgresql", "razor::config", "razor::microkernel" ] ],
		}
	}
}
