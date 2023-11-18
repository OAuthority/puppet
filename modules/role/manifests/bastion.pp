class role::bastion {
    include squid

    motd::role { 'role::bastion':
        description => 'core access bastion host'
    }

    ferm::service { 'bastion-ssh-public':
        proto => 'tcp',
        port  => '22',
    }

    $squid_access_hosts_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}'", ['networking'])
        .map |$key, $value| {
            "${value['networking']['ip']} ${value['networking']['ip6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )

    ferm::service { 'bastion-squid':
        proto  => 'tcp',
        port   => '8080',
        srange => "(${squid_access_hosts_str})",
    }

    $backends = lookup('varnish::backends')
    $firewall_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Role::Varnish]", ['networking'])
        .map |$key, $value| {
            "${value['networking']['ip']} ${value['networking']['ip6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )
    $firewall_rules_ports = join(
        $backends.map |$key, $value| {
            "${value['port']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )
    ferm::service { 'direct varnish access':
        proto   => 'tcp',
        port    => "(${firewall_rules_ports})",
        srange  => "(${firewall_rules_str})",
        notrack => true,
    }

    file { '/etc/nginx/sites-enabled/default':
        ensure => absent,
        notify => Service['nginx'],
    }

    nginx::site { 'mediawiki':
        ensure  => present,
        content => template('role/bastion/mediawiki.conf.erb'),
    }
}
