#
# == Class one::prerequisites
#
# Installation and Configuration of OpenNebula
# http://opennebula.org/
#
# === Author
# ePost Development GmbH
# (c) 2013
#
# Contributors:
# - Martin Alfke
# - Achim Ledermüller (Netways GmbH)
# - Sebastian Saemann (Netways GmbH)
# - Thomas Fricke (Endocode AG)
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::prerequisites {
    case $::osfamily {
        'RedHat': {
            if ( $one::params::one_repo_enable == true ) {
                yumrepo { 'opennebula':
                    baseurl  => 'http://opennebula.org/repo/CentOS/6/stable/$basearch/',
                    descr    => 'OpenNebula',
                    enabled  => 1,
                    gpgcheck => 0,
                }
            }
        }
        'Debian': {
            if ( $one::params::one_repo_enable == true ) {
                if ( $::operatingsystemmajrelease != 7) {
                    warning("No opennebula repo for $::operatingsystem $::operatingsystemmajrelease exists")
                } else {
                    package { 'python-software-properties':
                        ensure => installed,
                    }
                    file { '/etc/apt/sources.list.d/opennebula.list':
                        ensure => present,
                        content => "# opennebula\ndeb http://downloads.opennebula.org/repo/Debian/7/ stable opennebula",
                    }
                    exec { 'add opennebula key':
                      command   => '/usr/bin/wget -q -O- http://downloads.opennebula.org/repo/Debian/repo.key | /usr/bin/apt-key add - && /usr/bin/apt-get update',
                      subscribe => File['/etc/apt/sources.list.d/opennebula.list'],
                      require   => Package['python-software-properties'],
                    }
                }
            }
        }
        default: {
            notice('We use opennebula from default OS repositories.')
        }
    }
    group { 'oneadmin':
        ensure => present,
        gid    => $one::params::onegid,
    }
    user { 'oneadmin':
        ensure      => present,
        uid         => $one::params::oneuid,
        gid         => $one::params::onegid,
        home        => '/var/lib/one',
        managehome  => true,
        shell       => '/bin/bash'
    }
}
