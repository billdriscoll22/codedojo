$emscripten_deps = ["git", "openjdk-6-jdk", "nodejs"]
$clang_version = "3.2"
$clang_dir = "clang+llvm"
$clang_filename = "${clang_dir}.tar.gz"
$clang_url = "http://stanford.edu/~smbarber/codedojo/${clang_filename}"

$dev_tools = ["vim"]
$vimrc_dir = ".vim"
$vimrc_file = ".vimrc"
$vimrc_archive = "vimrc.tar.gz"
$vimrc_url = "http://stanford.edu/~smbarber/codedojo/${vimrc_archive}"

$emscripten_dir = "emscripten"
$emscripten_filename = "${emscripten_dir}.tar.gz"
$emscripten_url = "http://stanford.edu/~smbarber/codedojo/${emscripten_filename}"

stage { 'req-install': before => Stage['rvm-install'] }



class requirements {
  Exec {
    user => "vagrant",
    cwd => "/home/vagrant",
    logoutput => on_failure,
    environment => ["PWD=/home/vagrant", "HOME=/home/vagrant"],
    timeout => 0
  }
  exec { "/usr/bin/apt-get update":
    alias => "apt-get-update",
    cwd => "/root",
    user => "root";
  }
  package {
    ["postgresql", "postgresql-contrib", "libpq-dev"]: 
      ensure => installed, require => Exec['apt-get-update'];
    $dev_tools:
      ensure => "latest",
      require => Exec["apt-get-update"];
    $emscripten_deps:
      ensure => "latest",
      require => Exec["apt-get-update"];

    "python-software-properties":
      ensure => "latest",
      require => Exec["apt-get-update"];
  }
}

class installrvm {
  include rvm
  rvm::system_user { vagrant: ; }

    rvm_system_ruby {
      'ruby-1.9.3-p392':
        ensure => 'present';
    }
    rvm_gem {
      'ruby-1.9.3-p392/rails':
        ensure => latest,
        require => Rvm_system_ruby['ruby-1.9.3-p392'];
    }
    include installpassenger
  
  exec { "/usr/local/rvm/bin/rvm 1.9.3-p392@global do bundle install":
    alias => "bundle-install",
    cwd => "/vagrant",
    require => Rvm_system_ruby['ruby-1.9.3-p392'],
    environment => ["PWD=/vagrant", "HOME=/home/vagrant", "GEM_PATH=/usr/local/rvm/gems/ruby-1.9.3-p392:/usr/local/rvm/gems/ruby-1.9.3-p392@global", "RUBY_VERSION=ruby-1.9.3-p392"],
    user => "vagrant";
  }
}

class installpassenger {
  class {
    'rvm::passenger::apache':
      version => '3.0.11',
      ruby_version => 'ruby-1.9.3-p392',
      mininstances => '3',
      maxinstancesperapp => '0',
      maxpoolsize => '30',
      spawnmethod => 'smart-lv2';
  }
}

class doinstallrvm {
  class { requirements:, stage => "req-install" }
  include installrvm
}


class codedojo_dev {
  Exec {
    user => "vagrant",
    cwd => "/home/vagrant",
    logoutput => on_failure,
    environment => ["PWD=/home/vagrant", "HOME=/home/vagrant"],
    timeout => 0
  }
  file { "/home/vagrant/.bashrc":
    owner => vagrant,
    group => vagrant,
    mode => 664,
    source => "/vagrant/puppet/files/bashrc"
  }

  exec { "/usr/bin/wget ${vimrc_url}":
      alias => "wget-vimrc",
      cwd => "/tmp",
      creates => "/tmp/${vimrc_archive}",
      environment => ["PWD=/tmp", "HOME=/home/vagrant"],
  }

  exec { "/bin/tar -zxf /tmp/${vimrc_archive}":
      alias => "untar-vimrc",
      cwd => "/home/vagrant",
      environment => ["PWD=/home/vagrant", "HOME=/home/vagrant"],
      creates => ["/home/vagrant/${vimrc_dir}", "/home/vagrant/${vimrc_file}"],
      require => Exec["wget-vimrc"]
  }

}

class apache {
  service { "apache2":
    ensure => "running",
    enable => "true",
    require => Package["apache2"];
  }
  file { "/etc/apache2/sites-available/codedojo":
    owner => root,
    group => root,
    mode => 644,
    ensure => file,
    require => Package["apache2"],
    source => "/vagrant/puppet/files/codedojo";
  }
  file { "/etc/apache2/envvars":
    owner => root,
    group => root,
    mode => 644,
    ensure => file,
    require => Package["apache2"],
    source => "/vagrant/puppet/files/envvars";
  }
  exec { "/usr/sbin/a2dissite default":
    alias => "a2dis-default",
    cwd => "/root",
    require => Package["apache2"],
    notify => Service["apache2"],
    user => "root";
  }
  exec { "/usr/sbin/a2ensite codedojo":
    alias => "a2en-codedojo",
    cwd => "/root",
    require => File["/etc/apache2/sites-available/codedojo"],
    notify => Service["apache2"],
    user => "root";
  }
}

class installpg {
  include postgresql::server

  postgresql::db { 'codedojo':
    user => 'codedojo',
    password => 'currycurrycurrycurry';
  }
}

class emscripten {
  Exec {
    user => "root",
    cwd => "/opt",
    logoutput => on_failure,
    environment => ["PWD=/opt", "HOME=/root"],
    timeout => 0
  }
    file { "/home/vagrant/.emscripten":
        owner => vagrant,
        group => vagrant,
        mode => 664,
        source => "/vagrant/puppet/files/dot.emscripten"
    }

    file { "/var/www":
      owner => www-data,
      group => www-data,
      mode => 644,
      ensure => directory,
      require => Package["apache2"];
    }

    file { "/var/www/.emscripten":
        owner => www-data,
        group => www-data,
        mode => 664,
        source => "/vagrant/puppet/files/dot.emscripten",
        require => File["/var/www"]
    }

    exec { "/usr/bin/wget ${emscripten_url}":
        alias => "wget-emscripten",
        cwd => "/tmp",
        require => Package[$emscripten_deps],
        creates => "/tmp/${emscripten_filename}"
    }

    exec { "/bin/tar -zxf /tmp/${emscripten_filename}":
        alias => "untar-emscripten",
        cwd => "/opt",
        environment => ["PWD=/opt", "HOME=/root"],
        creates => "/opt/${emscripten_dir}",
        require => Exec["wget-emscripten"]
    }

    exec { "/usr/bin/wget ${clang_url}":
        alias => "wget-clang-llvm",
        cwd => "/tmp",
        creates => "/tmp/${clang_filename}",
    }

    exec { "/bin/tar -zxf /tmp/${clang_filename}":
        alias => "untar-clang-llvm",
        cwd => "/opt",
        environment => ["PWD=/opt", "HOME=/root"],
        creates => "/opt/bin",
        require => Exec["wget-clang-llvm"]
    }
}

group { "puppet":
  ensure => "present",
}

include emscripten
include codedojo_dev
include doinstallrvm
include apache

class { 'installpg': require => Service['postgresql'] }
