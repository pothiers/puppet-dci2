# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graph
# sudo ls /var/lib/puppet/state/graphs/

# include postgresql
include augeas
# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel
# include concat


Class['epel'] -> Package<||>{ provider => 'yum' }

class { 'redis':
  version        => '2.8.13',
  redis_password => 'test',
}


#! class { 'graphite': }

#ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos6.rpm
#ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos6.rpm
#sudo rpm -i irods-icat-4.0.3-64bit-centos6.rpm irods-database-plugin-postgres-1.3-centos6.rpm


#!yumrepo { 'renco':
#!  baseurl    => 'ftp://ftp.renci.org/pub/irods/releases/4.0.3/',
#!  #!baseurl    => 'ftp://ftp.renci.org/pub/irods/releases/',
#!  enabled    => 1,
#!  gpgcheck   => 0,
#!  priority   => 1,
#!  mirrorlist => absent,
#!} -> Package<| provider == 'yum' |>
#!
#!package { 'irods-icat': } 

#! package { 'irods-database-plugin-postgres': 
#!     source => 'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos6.rpm',
#! }


#sudo service postgresql initdb
#sudo service postgresql start
#sudo -u postgres createuser --no-createdb --no-createrole --no-superuser  pg-irods
#sudo -u postgres createdb  icat-db "icat catalog"

$dbuser = 'pg-irods'
$dbpass = 'noao-sdm'
class { 'postgresql::server': } 
postgresql::server::db { 'icat-db':
    user     => $dbuser,
    password => postgresql_password($dbuser,$dbpass),
  } 

package { ['postgresql-odbc',
           'unixODBC', 
           #! 'authd', 
           'fuse-libs', 
           'openssl098e',
          ]: } 

file { '/etc/irods':
    ensure => directory,
    } ->
file { '/etc/irods/service_account.config':
    content => "IRODS_SERVICE_ACCOUNT_NAME=irods\nIRODS_SERVICE_GROUP_NAME=irods",
    }

# Clear any existing rules and make sure that only rules defined in
# Puppet exist on the machine.
resources { "firewall":
  purge => true
}

Firewall {
  before  => Class['irods_fw::post'],
  require => Class['irods_fw::pre'],
}

class { ['irods_fw::pre', 'irods_fw::post']: }

class { 'firewall': }

class irods_fw::pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    state => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }->

 # IRODS
 firewall { '100 allow irods':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '1247',
    proto   => 'tcp',
    action  => 'accept',
    }->
 firewall { '101 allow irods':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '20000-20199',
    proto   => 'tcp',
    action  => 'accept',
    }->
 firewall { '102 allow irods':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '20000-20199',
    proto   => 'udp',
    action  => 'accept',
    }
}

class irods_fw::post {
  Firewall {
    require => undef,
  }
  # Default firewall rules
  # (none)
}

#wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos6.rpm
#sudo rpm -i irods-icat-4.0.3-64bit-centos6.rpm
#wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos6.rpm
#sudo rpm -i irods-database-plugin-postgres-1.3-centos6.rpm

wget::fetch { 'get irods-icat':
    source => 'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos6.rpm',
    destination => '/tmp/irods-icat-4.0.3-64bit-centos6.rpm',
    } ->
package { 'irods-icat':
    ensure => installed,
    provider => rpm,
    source => '/tmp/irods-icat-4.0.3-64bit-centos6.rpm',
  }

wget::fetch { 'get irods pg plugin':
    source => 'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos6.rpm',
    destination => '/tmp/irods-database-plugin-postgres-1.3-centos6.rpm',
    } 
#!package { 'irods-database-plugin-postgres':
#!    source => '/tmp/irods-database-plugin-postgres-1.3-centos6.rpm',
#!    provider => 'rpm',
#!  }




##############################################################################
### Still tto go
###

#! sudo sed -ibak s/-E//  /etc/xinetd.d/auth 
#! sudo /sbin/chkconfig --level=3 auth on
#! sudo /etc/init.d/xinetd restart

###
##############################################################################

yumrepo { 'ius':
  descr      => 'ius - stable',
  baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
  enabled    => 1,
  gpgcheck   => 0,
  priority   => 1,
  mirrorlist => absent,
} -> Package<| provider == 'yum' |>

class { 'python':
  version    => '34u',
  pip        => false,
  dev        => true,
  virtualenv => true,
}

package { 'python34u-pip': } ->
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} ->


package { 'graphviz-devel': } ->
python::requirements { '/vagrant/requirements.txt': }

python::pip {'daflsim': 
    pkgname => 'daflsim',
    url => 'https://github.com/pothiers/daflsim/archive/master.zip',
    }