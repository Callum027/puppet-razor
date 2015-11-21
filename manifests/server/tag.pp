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
define razor::server::tag
(
  $rule,
  $tag_name = $name,

  $ensure = 'present',

  # razor::params default values.
  $grep  = $::razor::params::grep,
  $razor = $::razor::params::razor,
)
{
  if ($ensure == 'present' or $ensure == present)
  {
    exec
    { "razor::server::tag::create::${name}":
      command => "${razor} create-tag --name ${tag_name} --rule '${rule}'",
      unless  => "${razor} tags | ${grep} '^| ${tag_name} |'",
      require => Class[['::razor::server', '::razor::config']],
    }
  }
  elsif ($ensure == 'absent' or $ensure == absent)
  {
    exec
    { "razor::server::tag::delete::${name}":
      command => "${razor} delete-tag --name ${tag_name}",
      onlyif  => "${razor} tag | ${grep} '^| ${tag_name} |'",
      require => Class[['::razor::server', '::razor::config']],
    }
  }
}
