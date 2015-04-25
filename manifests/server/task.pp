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
define razor::server::task
(
	$ensure			= "present",

	# Policy options.
	$task_name		= $name,
	$description		= undef,
	$os			= undef,
	$os_version,
	$base			= undef,
	$boot_sequence,
	$templates		= undef,

	$cat			= undef,
	$rm			= undef,
	$test			= undef,

	$tmp_dir		= undef,
	$razor_server_data_dir	= undef,
	$task_path		= undef
)
{
	require razor::params

	if ($cat == undef)
	{
		$cat = $razor::params::cat
	}

	if ($rm == undef)
	{
		$rm = $razor::params::rm
	}

	if ($test == undef)
	{
		$test = $razor::params::test
	}

	if ($tmp_dir == undef)
	{
		$tmp_dir = $razor::params::tmp_dir
	}

	if ($razor_server_data_dir == undef)
	{
		$razor_server_data_dir = $razor::params::razor_server_data_dir
	}

	if ($task_path == undef)
	{
		$task_path = $razor::params::config_yaml_all_task_path
	}

	if ($ensure == "present")
	{
		file
		{ "$razor_server_data_dir/$task_path/$task_name.task":
			ensure	=> "directory",
			owner	=> "razor",
			group	=> "razor",
			mode	=> 755,
		}
	}
	elsif ($ensure == "absent")
	{
		file
		{ "$razor_server_data_dir/$task_path/$task_name.task":
			ensure	=> $ensure,
		}
	}

	# The metadata file for this task.
	file
	{ "$razor_server_data_dir/$task_path/$task_name.task/metadata.yaml":
		ensure	=> $ensure,
		owner	=> "razor",
		group	=> "razor",
		mode	=> 755,
		content	=> template("razor/task/metadata.yaml.erb"),
		require	=> File["$razor_server_data_dir/$task_path/$task_name.task"],
	}

	# Any templates that are used in the task metadata.
	if ($templates != undef)
	{
		if ($ensure == "present")
		{
			file
			{ "$tmp_dir/razor-server-task-templates-create.sh":
				ensure	=> "present",
				owner	=> root,
				group	=> root,
				mode	=> 700,
				content	=> template("razor/task/template-create.sh.erb"),
			}

			file
			{ "$tmp_dir/razor-server-task-templates-create.sh":
				ensure	=> "absent",
			}

			exec
			{ "razor::server::task::template_create":
				command	=> "$tmp_dir/razor-server-task-templates-create.sh",
				require	=>
				[
					File["$tmp_dir/razor-server-task-templates-create.sh"],
					File["$razor_server_data_dir/$task_path/$task_name.task"]
				],
			}
		}
		else if ($ensure == "absent")
		{
			file
			{ "$tmp_dir/razor-server-task-templates-create.sh":
				ensure	=> "absent",
			}

			file
			{ "$tmp_dir/razor-server-task-templates-delete.sh":
				ensure	=> "present",
				owner	=> root,
				group	=> root,
				mode	=> 700,
				content	=> template("razor/task/template-delete.sh.erb"),
			}

			exec
			{ "razor::server::task::template_delete":
				command	=> "$tmp_dir/razor-server-task-templates-delete.sh",
				require	=>
				[
					File["$tmp_dir/razor-server-task-templates-delete.sh"],
					File["$razor_server_data_dir/$task_path/$task_name.task"]
				],
			}
		}

		file
		{ "$razor_server_data_dir/$task_path/$task_name.task/${template_keys}.erb":
			ensure	=> $ensure,
			owner	=> "razor",
			group	=> "razor",
			mode	=> 755,
			content	=> $template_values,
			require	=> File["$razor_server_data_dir/$task_path/$task_name.task"],
		}
	]
}
