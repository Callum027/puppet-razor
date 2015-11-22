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
  $ensure = 'present',
  $export = false,

  $db       = 'razor',
  $user     = 'razor',
  $password = 'mypass',
)
{
  if ($export == true)
  {
    if ($ensure == 'present' or ensure == present)
    {
      @@::postgresql::server::export
      { $::fqdn:
        db       => $db,
        user     => $user,
        password => $password,
      }
    }

    if (!(defined(Class['::postgresql::server'])))
    {
      if ($ensure == 'present' or $ensure == present)
      {
        class
        { '::postgresql::server':
          ip_mask_deny_postgres_user => '0.0.0.0/32',
          ip_mask_allow_all_users    => '0.0.0.0/0',
          listen_addresses           => '*',
          ipv4acls                   =>
          [
            'host all all 127.0.0.1/32 md5',
            'hostssl all all 0.0.0.0/0 md5'
          ],
        }

        contain ::postgresql::server
      }
    }
  }
  else
  {
    if (!(defined(Class['::postgresql::server'])))
    {
      if ($ensure == 'present' or $ensure == present)
      {
        class
        { '::postgresql::server':
          ipv4acls => ['host all all 127.0.0.1/32 md5'],
        }

        contain ::postgresql::server
      }
    }
  }

  if ($ensure == 'present' or $ensure == present)
  {
    ::postgresql::server::db
    { $db:
      user     => $user,
      password => postgresql_password($user, $password),
    }

    # Make sure the database gets initialised before the Razor Server
    # gets installed.
    if (defined(Class['::razor::server::install']))
    {
      ::Postgresql::Server::Db[$db] -> Class['::razor::server::install']
    }
  }
}
