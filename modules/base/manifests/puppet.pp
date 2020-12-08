# class base::puppet
class base::puppet (
    $puppet_major_version = lookup('puppet_major_version', {'default_value' => 6}),
    $puppetserver_hostname = lookup('puppetserver_hostname', {'default_value' => 'puppet2.miraheze.org'}),
) {

    apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => "puppet${puppet_major_version}",
        key      => {
            'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
            'server' => 'keyserver.ubuntu.com',
        },
    }

    package { 'puppet-agent':
        ensure  => present,
        require => Apt::Source['puppetlabs'],
    }

    # facter needs this for proper "virtual"/"is_virtual" resolution
    require_package('virt-what')

    file { '/usr/bin/facter':
        ensure  => link,
        target  => '/opt/puppetlabs/bin/facter',
        require => Package['puppet-agent'],
    }

    file { '/usr/bin/hiera':
        ensure  => link,
        target  => '/opt/puppetlabs/bin/hiera',
        require => Package['puppet-agent'],
    }

    file { '/usr/bin/puppet':
        ensure  => 'link',
        target  => '/opt/puppetlabs/bin/puppet',
        require => Package['puppet-agent'],
    }

    file { '/var/log/puppet':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0750',
    }

    cron { 'puppet-agent':
        command => '/usr/bin/puppet agent -tv >> /var/log/puppet/puppet.log',
        user    => 'root',
        hour    => '*',
        minute  => '*/10',
    }

    logrotate::conf { 'puppet':
        ensure => present,
        source => 'puppet:///modules/base/puppet/puppetlabs.puppet.logrotate.conf',
    }

    if !lookup('puppetserver') {
        file { '/etc/puppetlabs/puppet/puppet.conf':
            ensure  => present,
            content => template("base/puppet/puppet.${puppet_major_version}.conf.erb"),
            mode    => '0444',
            require => Package['puppet-agent'],
        }
    }

    service { 'puppet':
        ensure => stopped,
        enable => false,
    }

    file { '/usr/local/bin/puppet-enabled':
        mode   => '0555',
        owner  => 'root',
        group  => 'root',
        source => 'puppet:///modules/base/puppet/puppet-enabled',
    }

    motd::script { 'last-puppet-run':
        ensure   => present,
        priority => 97,
        source   => 'puppet:///modules/base/puppet/97-last-puppet-run',
    }
}
