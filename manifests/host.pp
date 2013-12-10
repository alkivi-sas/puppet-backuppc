define backuppc::host (
  $ip,
  $os,
  $backup_method      = 'rsyncd',
  $backup_data        = {},
  $blackout_periods   = [],
  $dumpPreUserCmd     = undef,
  $dumpPostUserCmd    = undef,
  $dumpPreShareCmd    = undef,
  $dumpPostShareCmd   = undef,
  $restorePreUserCmd  = undef,
  $restorePostUserCmd = undef,
  $archivePreUserCmd  = undef,
  $archivePostUserCmd = undef,
  $remote_user        = 'alkivi',
) {

  # quick check
  validate_string($title)
  validate_string($ip)
  validate_string($backup_method)
  validate_hash($backup_data)
  validate_string($remote_user)

  if(!is_ip_address($ip))
  {
    fail("Ip '${ip}' is not an ip address")
  }

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
        'user'         => $remote_user,
        'password'     => alkivi_password($title, 'hosts'),
      }
    }
    elsif($backup_method == 'rsyncd')
    {
      $template_data = {
        'key_shares'   => 'RsyncShareName',
        'key_user'     => 'RsyncdUserName',
        'key_password' => 'RsyncdPasswd',
        'user'         => $remote_user,
        'password'     => alkivi_password($title, 'hosts'),
      }
    }
    else
    {
      fail("Method ${backup_method} is not support for os ${os}")
    }

    # Generate a password
    alkivi_base::passwd { "backuppc-${title}":
      file => $title,
      type => 'hosts',
    }

    # Todo : create something for alkibox puppet master to be able to generate windows user on the fly :)

    # Generate generic conf
    file { "/etc/backuppc/${title}.pl":
      ensure  => present,
      owner   => 'backuppc',
      group   => 'www-data',
      mode    => '0640',
      content => template('backuppc/host.pl.erb'),
    }
  }
  elsif($os == 'osx')
  {
    if($backup_method == 'rsync')
    {
      $template_data = {
        'key_shares' => 'RsyncShareName',
        'extra_keys' => {
          'RsyncClientCmd'        => "\$sshPath -q -x -l ${remote_user} \$host nice -n 19 /usr/bin/sudo \$rsyncPath \$argList+",
          'RsyncClientRestoreCmd' => "\$sshPath -q -x -l ${remote_user} \$host nice -n 19 /usr/bin/sudo \$rsyncPath \$argList+",
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
