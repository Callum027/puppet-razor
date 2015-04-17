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
class razor::server::postgresql
(
	$ensure				= "present",

	$razor_admin			= $razor::params::razor_admin,

	$postgresql_user		= $razor::params::postgresql_user,
	$postgresql_password		= $razor::params::postgresql_password,

	$postgresql_development_db	= $razor::params::postgresql_development_db,
	$postgresql_test_db		= $razor::params::postgresql_test_db,
	$postgresql_production_db	= $razor::params::postgresql_production_db
) inherits razor::params
{
	class
	{ 'postgresql::server':
		ensure		=> $ensure,
		ipv4acls	=> [ 'host all all 127.0.0.1/32 md5' ],
	}

	if ($ensure == "present")
	{
		postgresql::server::role
		{ $postgresql_user:
			password_hash	=> postgresql_password($postgresql_user, $postgresql_password),
		}

		# Create the databases which Razor uses to store information about the
		# development, testing and production provisioning environments.
		exec
		{ "razor::server::postgresql::mirage_database_development":
			command	=> "$razor_admin -e development migrate-database",
			require	=> Class["razor::server::config"],
		}

		exec
		{ "razor::server::postgresql::mirage_database_test":
			command	=> "$razor_admin -e test migrate-database",
			require	=> Class["razor::server::config"],
		}

		exec
		{ "razor::server::postgresql::mirage_database_production":
			command	=> "$razor_admin -e production migrate-database",
			require	=> Class["razor::server::config"],
		}
	}
}
