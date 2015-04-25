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
define razor::server::policy
(
	$ensure			= "present",

	# Policy options.
	$policy_name		= $name,
	$hostname,
	$root_password,
	$broker,
	$task,

	$enabled		= undef,
	$max_count		= undef,
	$before			= undef,
	$after			= undef,
	$tags			= undef,
	$repo			= undef,
	$node_metadata		= undef,

	# Command dependencies.
	$grep			= undef,
	$razor			= undef,
	$rm			= undef,

	$tmp_dir		= undef
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
		{ "$tmp_dir/razor-server-policy-create.sh":
			owner	=> root,
			group	=> root,
			mode	=> 755,
			content	=> template("razor/razor-server-policy-create.sh.erb"),
		}

		exec
		{ "razor::server::policy:create":
			command	=> "$tmp_dir/razor-server-policy-create.sh",
			unless	=> "$razor policies | $grep '^| $policy_name |'",
			require	=>
			[
				Class[ [ "razor::client", "razor::install", "razor::postgresql", "razor::config", "razor::microkernel" ] ],
				File["$tmp_dir/razor-server-policy-create.sh"],
				Razor::server::broker[$broker],
				Razor::server::task[$task],
			],
		}

		if ($tags != undef)
		{
			Razor::server::tag[$tags] -> Exec["razor::server::policy::create"]
		}

		if ($repo != undef)
		{
			Razor::server::repo[$repo] -> Exec["razor::server::policy::create"]
		}
	}
	elsif ($ensure == "absent")
	{
		file
		{ "$tmp_dir/razor-server-policy-create.sh":
			ensure	=> $ensure,
		}

		exec
		{ "razor::server::policy::delete":
			command	=> "$razor delete-policy --name $policy_name",
			onlyif	=> "$razor policy | $grep '^| $policy_name |'",
			require	=> Class[ [ "razor::client", "razor::install", "razor::postgresql", "razor::config", "razor::microkernel" ] ],
		}
	}
}
