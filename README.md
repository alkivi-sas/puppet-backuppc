# BackupPC Module

This module will install and configure a BackupPC server and allow you to add other puppet managed nodes as clients/hosts. It
uses exported resources to create the client's configuration file

## Usage

### Minimal server configuration

```puppet
class { 'backuppc': }
```
This will do the typical install, configure and service management. The module manage apache by default. 
service that something has changed. Alternatively you can install backuppc as a virtual host or whatever else suits your needs.

Alkivi htpasswd and htaccess will be put in place, need to make this more generic

### More server configuration

```puppet
class { 'backuppc::server':
  wakeup_schedule   => [1, 2, 3, 4, 5, 21, 22, 23],
  max_backups       => 3,
  max_user_backups  => 1,
}
```
Please consult the BackupPC documentation for explanations on configuration options: http://backuppc.sourceforge.net/faq/BackupPC.html


### Host configuration

```puppet
class { 'backuppc::host':
    backup        => true,
    ip            => '192.168.10.1',
    os            => 'osx',
    backup_method => 'rsync',
    backup_data   => { '/' => ['Users'] },
}
```

backup boolean is necessary, because our host configuration is global (dhcp dns) and working with each loop was not possible at the time
ip, os and backup_method generate the host.pl according to the configuration
When using windows, a password is generated using alkivi_base class


## Limitations

* This module has been tested on Debian Wheezy, Squeeze.

## License

All the code is freely distributable under the terms of the LGPLv3 license.

## Contact

Need help ? contact@alkivi.fr

## Support

Please log tickets and issues at our [Github](https://github.com/alkivi-sas/)
