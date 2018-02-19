# Class: web
# ===========================
#
# Full description of class web here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'web':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class web {
  class { 'configurejava': }
  class { 'configuretomcat': }
  class { 'nagios': }
}

class configurejava {
  include apt
  $packages = ['openjdk-8-jdk', 'openjdk-8-jre']

  apt::ppa { 'ppa:openjdk-r/ppa': }->
  package { $packages:
     ensure => 'installed',
  }
}

class configuretomcat {
  tomcat::install { '/opt/tomcat':
    source_url => 'http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.5/bin/apache-tomcat-9.0.5.tar.gz'
  }
  tomcat::instance { 'default':
    catalina_home => '/opt/tomcat',
  }
  tomcat::war { 'ROOT.war':
    catalina_base => '/opt/tomcat',
    war_source    => 'https://s3.amazonaws.com/learnkarts-ram/notificationapp-latest.war',
  }
}

class nagios {
    include nagios::install
    include nagios::service
    include nagios::import
    include nagios::export
}

class nagios::install {
   package { ['nagios', 'nagios-plugins', 'nagios-nrpe-plugin' ]:
              ensure => present,
   }
}

class nagios::service {

    exec { 'fix-permissions':
      command  => "find /etc/nagios3/conf.d -type f -name '*cfg' | xargs chmod +r",
      refreshonly =>true,
    }

    service { 'nagios':
      ensure => running,
      enable => true,
      require => Class[ 'nagios::install' ],
    }
}

class nagios::import {
  Nagios_host <<||>> {
    require => Class[ 'nagios::install' ],
    notify  => Class[ 'nagios::service' ]
  }

  Nagios_service <<||>> {
     require => Class[ 'nagios::install' ],
     notify  => Class[ 'nagios::service' ]
  }
}


class nagios::nrpe {
    package {['nagios-nrpe-server', 'nagios-plugins' ]:
      ensure => present,
    }

    service { 'nagios-nrpe-server':
      ensure => running,
      enable => true,
      require => Package[ 'nagios-nrpe-server', 'nagios-plugins' ],
    }

}

class nagios::export {
   @@nagios_host { $::hostname :
        ensure => present,
        address => $::ipaddress,
        use  => 'generic-host',
        check_command  => 'check-host-alive',
        hostgroups => 'all-servers',
        target  => "/etc/nagios/conf.d/${::hostname}.cfg",
    }
}
 
