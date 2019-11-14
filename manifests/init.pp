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
#   [*package_ensure*]
#     Ensure present, latest or absent.
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
    Array $allow                                        = [],
    Array $deny                                         = [],
    Array $rules                                        = [],
    Stdlib::Absolutepath $logfile                       = '/var/log/rinetd.log',
    Boolean $logcommon                                  = false,
    Enum['present', 'latest', 'absent'] $package_ensure = 'present',
    Boolean $service_manage                             = true,
    Boolean $service_restart                            = true,
) {

    if $package_ensure == 'absent' {
        $service_ensure = 'stopped'
        $service_enable = false
    } else {
        $service_ensure = 'running'
        $service_enable = true
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
