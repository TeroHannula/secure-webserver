class secure-webserver {

# git clone ei toimi
# dvwa ei näy, kantaongelma?

	include apt

	apt::ppa { 'ppa:ondrej/php': }		# Repo for PHP5.6

	Package { allowcdrom => 'true', ensure => 'installed' }

	package { "apache2": }

	package { "git": }

	package { 'php5.6': }

	package { 'mysql-server': }

	package { 'php-mcrypt': }

	package { 'libapache2-mod-php5.6':
		require	=> Package['apache2'],
		notify => Service['apache2'],
	}

	package { 'php5.6-mysql':
		require => Package['mysql-server'],
	}

	package { 'libapache2-mod-security2':
		require => Package['apache2'],
	}

	file { '/etc/mysql/my.cnf':
		content => template("secure-webserver/my.cnf"),
		require => Package['mysql-server'],
		notify => Service["mysql"],		
	}

	file { '/var/www/html/phpinfo.php':
		content => template('secure-webserver/phpinfo.php'),
		owner => 'root',
		mode => '0755',
	}

	file { '/etc/modsecurity/modsecurity.conf':
		content => template('secure-webserver/modsecurity.conf'),
		require => Package['libapache2-mod-security2'],
	}

	service { "apache2":
		require => Package['apache2'],
		enable => 'true',
		ensure => 'running',
	}

	service { 'mysql':
		ensure => 'running',
		enable => 'true',
		require => Package['mysql-server'],
	}	

	exec { 'load-modsecurity':
		command => "/usr/sbin/a2enmod mod-security2",
		unless => "/bin/readlink -e /etc/apache2/mods-enabled/libapache2-modsecurity.load",
		notify => Service['apache2'],
	}

	exec { "mysql-password":
		command => '/usr/bin/mysqladmin -u root password p@ssw0rd -e "CREATE DATABASE dvwa"',
		notify => [Service['mysql'], Service["apache2"]],
		require => [Package['mysql-server'], Package["apache2"]], 
	}

	cron { 'updateRuleset':
		command => "usr/bin/git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /etc/modsecurity",
		ensure => 'present',
		user => 'root',
		hour => '4',
		minute => '0',
		weekday => '*',
		require => Package['libapache2-mod-security2'],
	}


#-------------- Install DVWA, tämä ehkä pois lopullisesta --------------


	exec { 'install-dvwa':
		require => Package['libapache2-mod-security2'],
		command => 'unzip files/v1.9.zip -d /var/www/html/',
		cwd	=> '/etc/puppet/modules/secure-webserver',
		path	=> '/usr/bin/',
		creates => '/var/www/html/DVWA-1.9',
	}

	exec { 'rename-dvwa':
		require	=> Exec['install-dvwa'],
		creates => '/var/www/html/dvwa/',
		path	=> '/bin/',
		command	=> 'mv /var/www/html/DVWA-1.9/ /var/www/html/dvwa/',
	}

}
