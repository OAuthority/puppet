# role: swift
class role::swift {
    include ::swift

    # http
    ufw::allow { 'swift mw1 8080':
        proto => 'tcp',
        port  => 8080,
        from  => '185.52.1.75',
    }

    ufw::allow { 'swift mw2 8080':
        proto => 'tcp',
        port  => 8080,
        from  => '185.52.2.113',
    }

    ufw::allow { 'swift mw3 8080':
        proto => 'tcp',
        port  => 8080,
        from  => '81.4.121.113',
    }

    ufw::allow { 'swift test1 8080':
        proto => 'tcp',
        port  => 8080,
        from  => '185.52.2.243',
    }

    ufw::allow { 'swift swift1 8080':
        proto => 'tcp',
        port  => 8080,
        from  => '81.4.101.157',
    }

    # nfs1 access swift1
    ufw::allow { 'swift swift1 6000':
        proto => 'tcp',
        port  => 6000,
        from  => '81.4.124.61',
    }

    ufw::allow { 'swift swift1 6001':
        proto => 'tcp',
        port  => 6001,
        from  => '81.4.124.61',
    }

    ufw::allow { 'swift swift1 6002':
        proto => 'tcp',
        port  => 6002,
        from  => '81.4.124.61',
    }

    ufw::allow { 'swift swift1 6003':
        proto => 'tcp',
        port  => 6003,
        from  => '81.4.124.61',
    }

    # misc4 access swift1
    ufw::allow { 'swift swift1 6000':
        proto => 'tcp',
        port  => 6000,
        from  => '185.52.3.121',
    }

    ufw::allow { 'swift swift1 6001':
        proto => 'tcp',
        port  => 6001,
        from  => '185.52.3.121',
    }

    ufw::allow { 'swift swift1 6002':
        proto => 'tcp',
        port  => 6002,
        from  => '185.52.3.121',
    }

    ufw::allow { 'swift swift1 6003':
        proto => 'tcp',
        port  => 6003,
        from  => '185.52.3.121',
    }

    motd::role { 'role::swift':
        description => 'Openstack Swift Object storage Proxy',
    }
}
