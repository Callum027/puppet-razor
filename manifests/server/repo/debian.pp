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
define razor::server::repo::debian
(
  $flavor   = 'netinst',
  $arch     = 'i386',
  $gui      = undef,

  $version  = undef,
  $codename = undef,

  $task         = 'debian',
  $iso_url      = undef, # Defined in body
  $archive_url  = undef, # Defined in body
  $archive_root = undef, # Defined in body
)
{
  $supported_arches = 
  [
    '^amd64$',
    '^arm64$',
    '^armel$',
    '^armhf$',
    '^i386$',
    '^mips$',
    '^mipsel$',
    '^powerpc$',
    '^ppc64el$',
    '^s390x$'
  ]

  validate_re($flavor, ['^netinst$', '^netboot$'], "valid values for flavor are 'netinst' and 'netboot'")
  validate_re($arch, $supported_arches, "unsupported arch, see http://debian.org/distrib for a list of compatible architectures")

  if ($flavor == 'netinst')
  {
    if ($version == undef)
    {
        fail("need to specify version number for the netinst flavor of Debian")
    }

    $_iso_url = pick($iso_url, "http://mirrors.kernel.org/debian-cd/${version}/${arch}/iso-cd/debian-${version}-${arch}-netinst.iso")
  }
  elsif ($flavor == 'netboot')
  {
    if ($codename == undef)
    {
        fail("need to specify codename for the netboot flavor of Debian")
    }

    $_archive_url = pick($archive_url, "http://ftp.nl.debian.org/debian/dists/${codename}/main/installer-${arch}/current/images/netboot/netboot.tar.gz")  
    $_archive_root = pick($archive_root, '/install/netboot')
  }

  ::razor::server::repo
  { $name:
    task         => $task,
    iso_url      => $_iso_url,
    archive_url  => $_archive_url,
    archive_root => $_archive_root,
  }
}
