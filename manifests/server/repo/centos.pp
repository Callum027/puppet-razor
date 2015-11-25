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
define razor::server::repo::centos
(
  $version,
  $flavor = 'Minimal',
  $arch   = 'i386',

  $task    = undef, # Defined in body
  $iso_url = undef, # Defined in body 
)
{
  validate_re($flavor, ['^DVD$', '^Minimal$', '^Everything$', '^NetInstall$'], "valid values for flavor are 'desktop' and 'server'")
  validate_re($arch, ['^i386$', '^x86_64$', '^aarch64$'], "valid values for arch are 'i386', 'x86_64' and 'aarch64'")

  if ($version =~ /^7/)
  {
    $_task = pick($task, 'centos/7')
  }
  elsif ($version =~ /^6/)
  {
    $_task = pick($task, 'centos/6')
  }
  else
  {
    $_task = pick($task, 'centos')
  }

  if ($version =~ /^7/ and $arch == 'x86_64' and $flavor == 'NetInstall')
  {
    fail("NetInstall flavor not available with CentOS 7 x86-64")
  }

  if ($version =~ /^7/ and $arch == 'aarch64' and $flavor == 'DVD')
  {
    fail("DVD flavor not available with CentOS 7 AArch64")
  }

  if ($version =~ /^[^7]/ and $arch == 'aarch64')
  {
    fail("AArch64 architecture not available with CentOS versions older than 7")
  }

  if ($iso_url == undef)
  {
    if ($version == '7' and $arch == 'x86_64')
    {
      $_iso_url = "http://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-${flavor}.iso"
    }
    elsif ($version == '7' and $arch != 'x86_64')
    {
      $_iso_url = "http://mirror.centos.org/altarch/7/isos/${arch}/CentOS-7-${arch}-${flavor}.iso"
    }
    else
    {
      $_iso_url = "http://mirrors.usc.edu/pub/linux/distributions/centos/${version}/isos/${arch}/CentOS-${version}-${arch}-${flavor}.iso"
    }
  }
  else
  {
    $_iso_url = $iso_url
  }

  ::razor::server::repo
  { $name:
    task    => $task,
    iso_url => $_iso_url,
  }
}
