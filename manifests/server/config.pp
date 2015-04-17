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
class razor::server::config
(
	$ensure				= "present",

	$config_dir			= $razor::params::config_dir,

	$postgresql_user		= $razor::params::postgresql_user,
	$postgresql_password		= $razor::params::postgresql_password,

	$postgresql_development_db	= $razor::params::postgresql_development_db,
	$postgresql_test_db		= $razor::params::postgresql_test_db,
	$postgresql_production_db	= $razor::params::postgresql_production_db
) inherits razor::params
{
	file
	{ "$config_dir/config.yaml":
		ensure	=> $ensure,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content	=> template("razor/config.yaml.erb"),
	}
}
