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
      $cat         = '/bin/cat'
      $razor       = '/usr/sbin/razor'
      $razor_admin = '/usr/sbin/razor-admin'
      $rm          = '/bin/rm'
      $tar         = '/bin/tar'

      # Working directories.
      $tmp_dir = '/tmp'

      # Razor Client configuration variables.
      $client_packages = 'razor-client'

      # Razor Server configuration variables.
      $server_packages = 'razor-server'
      $server_services = 'razor-server'

      $server_config_dir = '/etc/razor'
      $server_data_dir   = '/var/lib/razor'

      $razor_user  = 'razor'
      $razor_group = 'razor'

      # config.yaml options.
      $config_yaml_all_auth_enabled      = false
      $config_yaml_all_auth_config      = 'shiro.ini'

      $config_yaml_all_microkernel_debug_level  = 'debug'
      $config_yaml_all_microkernel_kernel_args  = ''
      $config_yaml_all_microkernel_extension_zip  = undef

      $config_yaml_all_secure_api      = false
      $config_yaml_all_protect_new_nodes    = false
      $config_yaml_all_match_nodes_on      = [ 'mac' ]
      $config_yaml_all_checkin_interval    = 15
      $config_yaml_all_task_path      = 'tasks'
      $config_yaml_all_repo_store_root    = "${razor_server_data_dir}/repo-store"
      $config_yaml_all_broker_path      = 'brokers'
      $config_yaml_all_hook_path      = 'hooks'

      $config_yaml_all_facts_blacklist    =
      [
        'domain',
        'filesystems',
        'fqdn',
        'hostname',
        'id',
        '/kernel.*/',
        'memoryfree',
        'memorysize',
        'memorytotal',
        '/operatingsystem.*/',
        'osfamily',
        'path',
        'ps',
        'rubysitedir',
        'rubyversion',
        'selinux',
        'sshdsakey',
        '/sshfp_[dr]sa/',
        'sshrsakey',
        '/swap.*/',
        'timezone',
        '/uptime.*/'
      ]
    }

    # RedHat support will come at a later time!

    default:
    {
      fail("Sorry, but the koha module does not support the ${::osfamily} OS family at this time")
    }
  }
}
