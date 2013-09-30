define backuppc::host (
  $ip,
  $mac,
  $comment,
  $os,
  $backup,
  $backup_method = 'rsyncd',
  $backup_data   = {},
) {

  validate_bool($backup)

  if($backup == true)
  {
    # quick check
    validate_string($title)
    validate_string($ip)
    validate_string($backup_method)
    validate_hash($backup_data)

    # generate password
    # require Class['alkivi_base:script']

    # TODO : deeper check on backup_method & co
    if(! member(['smb', 'rsync', 'rsyncd'], $backup_method))
    {
      fail("Method ${backup_method} is not supported")
    }

    if(! member(['win', 'osx', 'linux'], $os))
    {
      fail("OS ${os} is not supported")
    }

    concat::fragment { "backuppc-host-${title}":
      target  => '/etc/backuppc/hosts',
      content => "${title} 0\n",
      order   => 02,
    }

    if($os == 'win')
    {
      if($backup_method == 'smb')
      {
        $template_data = {
          'key_shares'   => 'SmbShareName',
          'key_user'     => 'SmbShareUserName',
          'key_password' => 'SmbSharePasswd',
          'user'         => 'alkivi',
          'password'     => 'CHANGEME',
        }
      }
      elsif($backup_method == 'rsyncd')
      {
        $template_data = {
          'key_shares'   => 'RsyncShareName',
          'key_user'     => 'RsyncdUserName',
          'key_password' => 'RsyncdPasswd',
          'user'         => 'alkivi',
          'password'     => 'CHANGEME',
        }
      }
      else
      {
        fail("Method ${backup_method} is not support for os ${os}")
      }

      # Generate a password
      alkivi_base::passwd { $title:
        type   => 'hosts',
        before => File["/etc/backuppc/${title}.pl.temp"],
      }

      # Todo : create something for alkibox puppet master to be able to generate windows user on the fly :)

      # Generate generic conf
      file { "/etc/backuppc/${title}.pl.temp":
        ensure  => present,
        owner   => 'backuppc',
        group   => 'www-data',
        mode    => '0640',
        content => template('backuppc/host.pl.erb'),
      }

      # Fix password
      exec { "/etc/backuppc/${title}.password":
        command  => "PASSWORD=`cat /root/.passwd/hosts/${title}` && sed 's/CHANGEME/'\$PASSWORD'/' /etc/backuppc/${title}.pl.temp > /etc/backuppc/${title}.pl",
        provider => 'shell',
        creates  => "/etc/backuppc/${title}.pl",
        path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
        require  => File["/etc/backuppc/${title}.pl.temp"],
        notify   => Class['backuppc::service'],
      }
    }
    elsif($os == 'osx')
    {
      if($backup_method == 'rsync')
      {
        $template_data = {
          'key_shares' => 'RsyncShareName',
          'extra_keys' => {
            'RsyncClientCmd'        => '$sshPath -q -x -l alkivi $host nice -n 19 /usr/bin/sudo $rsyncPath $argList+',
            'RsyncClientRestoreCmd' => '$sshPath -q -x -l alkivi $host nice -n 19 /usr/bin/sudo $rsyncPath $argList+',
          }
        }
      }
      else
      {
        fail("Method ${backup_method} is not support for os ${os}")
      }

      # Generate generic conf
      file { "/etc/backuppc/${title}.pl":
        ensure  => present,
        owner   => 'backuppc',
        group   => 'www-data',
        mode    => '0640',
        content => template('backuppc/host.pl.erb'),
      }
    }
    elsif($os == 'linux')
    {
      if($backup_method == 'rsync')
      {
        $template_data = {
          'key_shares' => 'RsyncShareName',
          'extra_keys' => {
            'RsyncClientCmd'        => '$sshPath -q -x -l alkivi $host nice -n 19 /usr/bin/sudo $rsyncPath $argList+',
            'RsyncClientRestoreCmd' => '$sshPath -q -x -l alkivi $host nice -n 19 /usr/bin/sudo $rsyncPath $argList+',
          }
        }
      }
      else
      {
        fail("Method ${backup_method} is not support for os ${os}")
      }

      # Generate generic conf
      file { "/etc/backuppc/${title}.pl":
        ensure  => present,
        owner   => 'backuppc',
        group   => 'www-data',
        mode    => '0640',
        content => template('backuppc/host.pl.erb'),
      }
    }
  }
}
