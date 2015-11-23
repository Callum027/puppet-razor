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
define razor::server::repo::ubuntu
(
  $flavor   = 'netboot',
  $arch     = 'i386',

  $release  = undef,
  $codename = undef,
  $backport = undef,

  $task    = 'ubuntu',
  $iso_url = undef, # Defined in body
  $url     = undef, # Defined in body
)
{
  validate_re($flavor, ['^netboot$', '^server$'], "valid values for flavor are 'desktop' and 'server'")
  validate_re($arch, ['^i386$', '^amd64$'], "valid values for arch are 'i386' and 'amd64'")

  if ($flavor == 'server')
  {
    if ($release == undef)
    {
        fail("need to specify release number for the server flavor of Ubuntu")
    }

    $_iso_url = pick($iso_url, "http://cdimage.ubuntu.com/${release}/releases/ubuntu-${release}-${flavor}-${arch}.iso")
  }
  elsif ($flavor == 'netboot')
  {
    if ($codename == undef)
    {
        fail("need to specify codename for the netboot flavor of Ubuntu")
    }

    if ($backport != undef)
    {
      $_url = pick($url, "http://archive.ubuntu.com/ubuntu/dists/${codename}-updates/main/installer-${arch}/current/images/netboot")
    }
    else
    {
      $_url = pick($url, "http://archive.ubuntu.com/ubuntu/dists/${codename}-updates/main/installer-${arch}/current/images/${backport}-netboot")  
    }
  }

  ::razor::server::repo
  { $name:
    task    => $task,
    iso_url => $_iso_url,
    url     => $_url,
  }
}
