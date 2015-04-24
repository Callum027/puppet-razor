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
class razor::server::microkernel
(
	$ensure					= "present",
	$tmp_dir				= $razor::params::tmp_dir,
	$microkernel_url			= $razor::params::microkernel_url,
	$config_yaml_all_repo_store_root	= $config::params::config_yaml_all_repo_store_root
) inherits razor::params
{
	if ($ensure == "present")
	{
		exec
		{ "razor::server::microkernel::download_microkernel":
			command	=> "$wget -r -t 5 $microkernel_url -O $tmp_dir/microkernel.tar",
			creates	=> "$tmp_dir/microkernel.tar",
			unless	=> "$test -f \"$config_yaml_all_repo_store_root/initrd0.img\" -a -f \"$config_yaml_all_repo_store_root/vmlinuz\"",
		}

		exec
		{ "razor::server::microkernel::extract_microkernel":
			command	=> "$tar --overwrite -xf $tmp_dir/microkernel.tar $config_yaml_all_repo_store_root",
			creates	=> "$tmp_dir/microkernel.tar",
			unless	=> "$test -f \"$config_yaml_all_repo_store_root/initrd0.img\" -a -f \"$config_yaml_all_repo_store_root/vmlinuz0\"",
			require	=> Exec["razor::server::microkernel::download_microkernel"],
		}

		file
		{ "$tmp_dir/microkernel.tar":
			ensure	=> "absent",
			require	=> Exec[["razor::server::microkernel::download_microkernel", "razor::server::microkernel::extract_microkernel"]], 
		}
	}
	else
	{
		file
		{ "$tmp_dir/microkernel.tar":
			ensure	=> "absent",
		}
	}

	file
	{ [ "$config_yaml_all_repo_store_root/initrd0.img", "$config_yaml_all_repo_store_root/vmlinuz0" ]:
		ensure	=> $ensure,
		owner	=> $razor_user,
		group	=> $razor_group,
		mode	=> 755,
		require	=> Exec[["razor::server::microkernel::download_microkernel", "razor::server::microkernel::extract_microkernel"]],
	}
}
