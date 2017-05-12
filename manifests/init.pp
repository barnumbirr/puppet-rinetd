# == Class: rinetd
#
# This class initializes the rinetd(8) class
#
# Parameters:
#   [*allow*]
#     Set global allow rules.
#     Only IP addresses are matched, hostnames cannot be specified.
#     Possible wildcards are * and ?
#     Default: []
#
#   [*autoupgrade*]
#     Upgrade package automatically, if there is a newer version.
#     Default: false
#
#   [*deny*]
#     Set global deny rules.
#     Only IP addresses are matched, hostnames cannot be specified.
#     Possible wildcards are * and ?
#     Default: []
#
#   [*rules*]
#     Set forwarding rules.
#     Both IP addresses and hostnames are accepted for bindaddress and connectaddress.
#     Default: []
#
#   [*logfile*]
#     Set logfile path.
#     Default: /var/log/rinetd.log
#
#   [*logcommon*]
#     Activate web server-style "common log format" logging.
#     Default: false
#
#   [*ensure*]
#     Ensure if present or absent.
#     Default: present
#
#   [*service_manage*]
#     Whether service state should be managed by Puppet.
#     Default: true
#
#   [*service_restart*]
#     Force service restart after configuration file is modified.
#     Default: true
#
# Actions:
#   Installs and configures rinetd(8).
#
# Sample Usage:
#   See README
#
class rinetd(
    $allow           = [],
    $autoupgrade     = false,
    $deny            = [],
    $rules           = [],
    $logfile         = '/var/log/rinetd.log',
    $logcommon       = false,
    $ensure          = 'present',
    $service_manage  = true,
    $service_restart = true,
) {

    validate_array($allow)
    validate_array($deny)
    validate_array($rules)

    validate_bool($autoupgrade)
    validate_bool($logcommon)
    validate_bool($service_manage)
    validate_bool($service_restart)

    validate_absolute_path($logfile)

    validate_string($ensure)

    case $ensure {
        /(present)/: {
            if $autoupgrade == true {
                $package_ensure = 'latest'
            } else {
                $package_ensure = 'present'
            }
            $service_ensure = 'running'
            $service_enable = true
        }
        /(absent)/: {
            $package_ensure = 'absent'
            $service_ensure = 'stopped'
            $service_enable = false
        }
        /(purged)/: {
            $package_ensure = 'purged'
            $service_ensure = 'stopped'
            $service_enable = false
        }
        default: {
            fail('ensure parameter must be present, absent or purged')
        }
    }

    package { 'rinetd':
        ensure   => $package_ensure,
    }

    if $service_restart and $service_manage {
        $service_notify_real = Service['rinetd']
    } else {
        $service_notify_real = undef
    }

    if $service_manage {
        service { 'rinetd':
            ensure     => $service_ensure,
            enable     => $service_enable,
            hasrestart => true,
            require    => Package['rinetd']
        }
    }

    file { 'rinetd_conf':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        path    => '/etc/rinetd.conf',
        content => template('rinetd/rinetd.conf.erb'),
        require => Package['rinetd'],
        notify  => $service_notify_real,
    }
}
