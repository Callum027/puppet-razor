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
define razor::server::hook
(
	$ensure		= "present",

	$hook_name	= $name,

	$hook_type,
	$configuration,

	$grep		= undef,
	$razor		= undef,
	$rm		= undef,

	$tmp_dir	= undef
)
{
	require razor::params

	# TODO: Change this to build configuration.yaml and the event files
	# directly from templates.

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
		{ "$tmp_dir/razor-server-hook-create.sh":
			owner	=> root,
			group	=> root,
			mode	=> 755,
			content	=> template("razor/razor-server-hook-create.sh.erb"),
		}

		exec
		{ "razor::server::hook:create":
			command	=> "$tmp_dir/razor-server-hook-create.sh",
			unless	=> "$razor hooks | $grep '^| $repo_name |'",
			require	=>
			[
				Class[ [ "razor::client", "razor::install", "razor::postgresql", "razor::config", "razor::microkernel" ] ],
				File["$tmp_dir/razor-server-hook-create.sh"]
			],
		}
	}
	elsif ($ensure == "absent")
	{
		file
		{ "$tmp_dir/razor-server-hook-create.sh":
			ensure	=> $ensure,
		}

		exec
		{ "razor::server::hook::delete":
			command	=> "$razor delete-hook --name $hook_name",
			onlyif	=> "$razor hook | $grep '^| $hook_name |'",
			require	=> Class[ [ "razor::client", "razor::install", "razor::postgresql", "razor::config", "razor::microkernel" ] ],
		}
	}
}
