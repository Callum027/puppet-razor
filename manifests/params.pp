# == Class: koha::params
#
# Defines values for other classes in the Koha module to use.
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
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2015 Callum Dickinson.
#
class razor::params
{
	case $::osfamily
	{
		'Debian':
		{
			# Executable files.
			$razor				= "/usr/sbin/razor"
			$razor_admin			= "/usr/sbin/razor-admin"

			# Razor Client configuration variables.
			$razor_client_packages		= "razor-client"

			# Razor Server configuration variables.
			$razor_server_packages		= "razor-server"
			$razor_server_services		= "razor-server"

			# PostgreSQL configuration variables.
			$postgresql_user		= "razor"
			$postgresql_password		= $postgresql_user

			$postgresql_development_db	= "razor_dev"
			$postgresql_test_db		= "razor_test"
			$postgresql_production_db	= "razor_prd"
		}

		# RedHat support will come at a later time!

		default:
		{
			fail("Sorry, but the koha module does not support the $::osfamily OS family at this time")
		}
	}
}
