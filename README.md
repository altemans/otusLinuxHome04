# Home 04 ZFS

<details>
  <summary>home 04</summary>

### Определение алгоритма с наилучшим сжатием

```
[vagrant@zfs ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 

[vagrant@zfs ~]$ sudo zpool create mir1 mirror /dev/sdb /dev/sdc
[vagrant@zfs ~]$ sudo zpool create mir2 mirror /dev/sdd /dev/sde
[vagrant@zfs ~]$ sudo zpool create mir3 mirror /dev/sdf /dev/sdg
[vagrant@zfs ~]$ sudo zpool create mir4 mirror /dev/sdh /dev/sdi
[vagrant@zfs ~]$ sudo zpool list
NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
mir1   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
mir2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
mir3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
mir4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -

[vagrant@zfs ~]$ sudo zfs set compression=lzjb mir1
[vagrant@zfs ~]$ sudo zfs set compression=lz4 mir2
[vagrant@zfs ~]$ sudo zfs set compression=gzip-9 mir3
[vagrant@zfs ~]$ sudo zfs set compression=zle mir4
[vagrant@zfs ~]$ sudo zfs get all | grep compression
mir1  compression           lzjb                   local
mir2  compression           lz4                    local
mir3  compression           gzip-9                 local
mir4  compression           zle                    local



[vagrant@zfs ~]$ for i in {1..4}; do sudo wget -P /mir$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2023-04-08 20:17:01--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40922255 (39M) [text/plain]
Saving to: '/mir1/pg2600.converter.log'

100%[=================================================================================================================================================>] 40,922,255   224KB/s   in 2m 10s 

2023-04-08 20:19:13 (307 KB/s) - '/mir1/pg2600.converter.log' saved [40922255/40922255]

--2023-04-08 20:19:13--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40922255 (39M) [text/plain]
Saving to: '/mir2/pg2600.converter.log'

100%[=================================================================================================================================================>] 40,922,255   617KB/s   in 1m 41s 

2023-04-08 20:20:55 (396 KB/s) - '/mir2/pg2600.converter.log' saved [40922255/40922255]

--2023-04-08 20:20:55--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40922255 (39M) [text/plain]
Saving to: '/mir3/pg2600.converter.log'


100%[===========================================================================================================================================================>] 40,922,255   320KB/s   in 80s    

2023-04-08 20:22:17 (501 KB/s) - '/mir3/pg2600.converter.log' saved [40922255/40922255]

--2023-04-08 20:22:17--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40922255 (39M) [text/plain]
Saving to: '/mir4/pg2600.converter.log'

100%[===========================================================================================================================================================>] 40,922,255   985KB/s   in 79s    

2023-04-08 20:23:37 (504 KB/s) - '/mir4/pg2600.converter.log' saved [40922255/40922255]



[vagrant@zfs ~]$ ls -l /mir*
/mir1:
total 22047
-rw-r--r--. 1 root root 40922255 Apr  2 08:18 pg2600.converter.log

/mir2:
total 17986
-rw-r--r--. 1 root root 40922255 Apr  2 08:18 pg2600.converter.log

/mir3:
total 10955
-rw-r--r--. 1 root root 40922255 Apr  2 08:18 pg2600.converter.log

/mir4:
total 39992
-rw-r--r--. 1 root root 40922255 Apr  2 08:18 pg2600.converter.log

[vagrant@zfs ~]$ zfs list
NAME   USED  AVAIL     REFER  MOUNTPOINT
mir1  21.7M   330M     21.6M  /mir1
mir2  17.7M   334M     17.6M  /mir2
mir3  10.8M   341M     10.7M  /mir3
mir4  39.2M   313M     39.1M  /mir4


[vagrant@zfs ~]$ zfs get all | grep compressratio | grep -v ref
mir1  compressratio         1.81x                  -
mir2  compressratio         2.22x                  -
mir3  compressratio         3.65x                  -
mir4  compressratio         1.00x                  -
```
### Определение настроек пула

```
wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
...
Saving to: 'archive.tar.gz'

100%[=================================================================================================================================================>] 7,275,140   1.67MB/s   in 4.3s   

2023-04-08 21:14:18 (1.62 MB/s) - 'archive.tar.gz' saved [7275140/7275140]

[vagrant@zfs ~]$ ls                           
archive.tar.gz  zpoolexport
[vagrant@zfs ~]$ sudo zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                                 ONLINE
          mirror-0                           ONLINE
            /home/vagrant/zpoolexport/filea  ONLINE
            /home/vagrant/zpoolexport/fileb  ONLINE

[vagrant@zfs ~]$ sudo zpool import -d zpoolexport/ otus
[vagrant@zfs ~]$ zpool status
...
  pool: otus
 state: ONLINE
  scan: none requested
config:

        NAME                                 STATE     READ WRITE CKSUM
        otus                                 ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
            /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

[vagrant@zfs ~]$ sudo zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupditto                     0                              default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      2856866867842134933            -
otus  autotrim                       off                            default
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local

[vagrant@zfs ~]$ sudo zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -

[vagrant@zfs ~]$ sudo zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default

[vagrant@zfs ~]$ sudo zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local

[vagrant@zfs ~]$ sudo zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local

[vagrant@zfs ~]$ sudo zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local

```
### Работа со снапшотом, поиск сообщения от преподавателя

```
[vagrant@zfs ~]wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"
...
Saving to: 'otus_task2.file'

100%[=================================================================================================================================================>] 5,432,736   1.60MB/s   in 3.2s   

2023-04-08 21:22:48 (1.60 MB/s) - 'otus_task2.file' saved [5432736/5432736]

[vagrant@zfs ~]$ sudo zfs receive otus/test@today < otus_task2.file
[vagrant@zfs ~]$ find /otus/test -iname "secret_mes*"
/otus/test/task1/file_mess/secret_message

[vagrant@zfs ~]$ cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome

```

</details>

# Вывод запуска vagrant up со скриптом

<details>
  <summary>vagrant up</summary>
  

```
altemans@Home01:~/otus/home04$ vagrant up
Bringing machine 'zfs' up with 'virtualbox' provider...
==> zfs: Importing base box 'centos/7'...
==> zfs: Matching MAC address for NAT networking...
==> zfs: Setting the name of the VM: home04_zfs_1681078577421_89777
==> zfs: Fixed port collision for 22 => 2222. Now on port 2200.
==> zfs: Clearing any previously set network interfaces...
==> zfs: Preparing network interfaces based on configuration...
    zfs: Adapter 1: nat
==> zfs: Forwarding ports...
    zfs: 22 (guest) => 2200 (host) (adapter 1)
==> zfs: Running 'pre-boot' VM customizations...
==> zfs: Booting VM...
==> zfs: Waiting for machine to boot. This may take a few minutes...
    zfs: SSH address: 127.0.0.1:2200
    zfs: SSH username: vagrant
    zfs: SSH auth method: private key
    zfs: 
    zfs: Vagrant insecure key detected. Vagrant will automatically replace
    zfs: this with a newly generated keypair for better security.
    zfs: 
    zfs: Inserting generated public key within guest...
    zfs: Removing insecure key from the guest if it's present...
    zfs: Key inserted! Disconnecting and reconnecting using new SSH key...
==> zfs: Machine booted and ready!
==> zfs: Checking for guest additions in VM...
    zfs: No guest additions were detected on the base box for this VM! Guest
    zfs: additions are required for forwarded ports, shared folders, host only
    zfs: networking, and more. If SSH fails on this machine, please install
    zfs: the guest additions and repackage the box to continue.
    zfs: 
    zfs: This is not an error message; everything may continue to work properly,
    zfs: in which case you may ignore this message.
==> zfs: Setting hostname...
==> zfs: Rsyncing folder: /home/altemans/otus/home04/ => /vagrant
==> zfs: Running provisioner: file...
    zfs: ./get_disks_no_root.sh => ./get_disks_no_root.sh
==> zfs: Running provisioner: shell...
    zfs: Running: /tmp/vagrant-shell20230410-147516-1nn8848.sh
    zfs: Loaded plugins: fastestmirror
    zfs: Examining /var/tmp/yum-root-_1TveK/zfs-release.el7_8.noarch.rpm: zfs-release-1-7.8.noarch
    zfs: Marking /var/tmp/yum-root-_1TveK/zfs-release.el7_8.noarch.rpm to be installed
    zfs: Resolving Dependencies
    zfs: --> Running transaction check
    zfs: ---> Package zfs-release.noarch 0:1-7.8 will be installed
    zfs: --> Finished Dependency Resolution
    zfs: 
    zfs: Dependencies Resolved
    zfs: 
    zfs: ================================================================================
    zfs:  Package          Arch        Version      Repository                      Size
    zfs: ================================================================================
    zfs: Installing:
    zfs:  zfs-release      noarch      1-7.8        /zfs-release.el7_8.noarch      2.9 k
    zfs: 
    zfs: Transaction Summary
    zfs: ================================================================================
    zfs: Install  1 Package
    zfs: 
    zfs: Total size: 2.9 k
    zfs: Installed size: 2.9 k
    zfs: Downloading packages:
    zfs: Running transaction check
    zfs: Running transaction test
    zfs: Transaction test succeeded
    zfs: Running transaction
    zfs:   Installing : zfs-release-1-7.8.noarch                                     1/1
    zfs:   Verifying  : zfs-release-1-7.8.noarch                                     1/1
    zfs: 
    zfs: Installed:
    zfs:   zfs-release.noarch 0:1-7.8
    zfs: 
    zfs: Complete!
    zfs: Loaded plugins: fastestmirror
    zfs: Determining fastest mirrors
    zfs:  * base: mirror.mijn.host
    zfs:  * extras: mirror.mijn.host
    zfs:  * updates: ftp.tudelft.nl
    zfs: Resolving Dependencies
    zfs: --> Running transaction check
    zfs: ---> Package epel-release.noarch 0:7-11 will be installed
    zfs: ---> Package kernel-devel.x86_64 0:3.10.0-1160.88.1.el7 will be installed
    zfs: --> Processing Dependency: perl for package: kernel-devel-3.10.0-1160.88.1.el7.x86_64
    zfs: ---> Package zfs.x86_64 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: zfs-kmod = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzpool2 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzfs2 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libuutil1 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libnvpair1 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: sysstat for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzpool.so.2()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzfs_core.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzfs.so.2()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libuutil.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libnvpair.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Running transaction check
    zfs: ---> Package libnvpair1.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libuutil1.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libzfs2.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libzpool2.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package perl.x86_64 4:5.16.3-299.el7_9 will be installed
    zfs: --> Processing Dependency: perl-libs = 4:5.16.3-299.el7_9 for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Socket) >= 1.3 for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Scalar::Util) >= 1.10 for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl-macros for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl-libs for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(threads::shared) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(threads) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(constant) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Time::Local) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Time::HiRes) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Storable) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Socket) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Scalar::Util) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Pod::Simple::XHTML) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Pod::Simple::Search) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Getopt::Long) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Filter::Util::Call) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(File::Temp) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(File::Spec::Unix) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(File::Spec::Functions) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(File::Spec) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(File::Path) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Exporter) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Cwd) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: perl(Carp) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: --> Processing Dependency: libperl.so()(64bit) for package: 4:perl-5.16.3-299.el7_9.x86_64
    zfs: ---> Package sysstat.x86_64 0:10.1.5-20.el7_9 will be installed
    zfs: --> Processing Dependency: libsensors.so.4()(64bit) for package: sysstat-10.1.5-20.el7_9.x86_64
    zfs: ---> Package zfs-dkms.noarch 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: dkms >= 2.2.0.3 for package: zfs-dkms-0.8.5-1.el7.noarch
    zfs: --> Processing Dependency: gcc for package: zfs-dkms-0.8.5-1.el7.noarch
    zfs: --> Running transaction check
    zfs: ---> Package gcc.x86_64 0:4.8.5-44.el7 will be installed
    zfs: --> Processing Dependency: libgomp = 4.8.5-44.el7 for package: gcc-4.8.5-44.el7.x86_64
    zfs: --> Processing Dependency: cpp = 4.8.5-44.el7 for package: gcc-4.8.5-44.el7.x86_64
    zfs: --> Processing Dependency: libgcc >= 4.8.5-44.el7 for package: gcc-4.8.5-44.el7.x86_64
    zfs: --> Processing Dependency: glibc-devel >= 2.2.90-12 for package: gcc-4.8.5-44.el7.x86_64
    zfs: --> Processing Dependency: libmpfr.so.4()(64bit) for package: gcc-4.8.5-44.el7.x86_64
    zfs: --> Processing Dependency: libmpc.so.3()(64bit) for package: gcc-4.8.5-44.el7.x86_64
    zfs: ---> Package lm_sensors-libs.x86_64 0:3.4.0-8.20160601gitf9185e5.el7 will be installed
    zfs: ---> Package perl-Carp.noarch 0:1.26-244.el7 will be installed
    zfs: ---> Package perl-Exporter.noarch 0:5.68-3.el7 will be installed
    zfs: ---> Package perl-File-Path.noarch 0:2.09-2.el7 will be installed
    zfs: ---> Package perl-File-Temp.noarch 0:0.23.01-3.el7 will be installed
    zfs: ---> Package perl-Filter.x86_64 0:1.49-3.el7 will be installed
    zfs: ---> Package perl-Getopt-Long.noarch 0:2.40-3.el7 will be installed
    zfs: --> Processing Dependency: perl(Pod::Usage) >= 1.14 for package: perl-Getopt-Long-2.40-3.el7.noarch
    zfs: --> Processing Dependency: perl(Text::ParseWords) for package: perl-Getopt-Long-2.40-3.el7.noarch
    zfs: ---> Package perl-PathTools.x86_64 0:3.40-5.el7 will be installed
    zfs: ---> Package perl-Pod-Simple.noarch 1:3.28-4.el7 will be installed
    zfs: --> Processing Dependency: perl(Pod::Escapes) >= 1.04 for package: 1:perl-Pod-Simple-3.28-4.el7.noarch
    zfs: --> Processing Dependency: perl(Encode) for package: 1:perl-Pod-Simple-3.28-4.el7.noarch
    zfs: ---> Package perl-Scalar-List-Utils.x86_64 0:1.27-248.el7 will be installed
    zfs: ---> Package perl-Socket.x86_64 0:2.010-5.el7 will be installed
    zfs: ---> Package perl-Storable.x86_64 0:2.45-3.el7 will be installed
    zfs: ---> Package perl-Time-HiRes.x86_64 4:1.9725-3.el7 will be installed
    zfs: ---> Package perl-Time-Local.noarch 0:1.2300-2.el7 will be installed
    zfs: ---> Package perl-constant.noarch 0:1.27-2.el7 will be installed
    zfs: ---> Package perl-libs.x86_64 4:5.16.3-299.el7_9 will be installed
    zfs: ---> Package perl-macros.x86_64 4:5.16.3-299.el7_9 will be installed
    zfs: ---> Package perl-threads.x86_64 0:1.87-4.el7 will be installed
    zfs: ---> Package perl-threads-shared.x86_64 0:1.43-6.el7 will be installed
    zfs: ---> Package zfs-dkms.noarch 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: dkms >= 2.2.0.3 for package: zfs-dkms-0.8.5-1.el7.noarch
    zfs: --> Running transaction check
    zfs: ---> Package cpp.x86_64 0:4.8.5-44.el7 will be installed
    zfs: ---> Package glibc-devel.x86_64 0:2.17-326.el7_9 will be installed
    zfs: --> Processing Dependency: glibc-headers = 2.17-326.el7_9 for package: glibc-devel-2.17-326.el7_9.x86_64
    zfs: --> Processing Dependency: glibc = 2.17-326.el7_9 for package: glibc-devel-2.17-326.el7_9.x86_64
    zfs: --> Processing Dependency: glibc-headers for package: glibc-devel-2.17-326.el7_9.x86_64
    zfs: ---> Package libgcc.x86_64 0:4.8.5-39.el7 will be updated
    zfs: ---> Package libgcc.x86_64 0:4.8.5-44.el7 will be an update
    zfs: ---> Package libgomp.x86_64 0:4.8.5-39.el7 will be updated
    zfs: ---> Package libgomp.x86_64 0:4.8.5-44.el7 will be an update
    zfs: ---> Package libmpc.x86_64 0:1.0.1-3.el7 will be installed
    zfs: ---> Package mpfr.x86_64 0:3.1.1-4.el7 will be installed
    zfs: ---> Package perl-Encode.x86_64 0:2.51-7.el7 will be installed
    zfs: ---> Package perl-Pod-Escapes.noarch 1:1.04-299.el7_9 will be installed
    zfs: ---> Package perl-Pod-Usage.noarch 0:1.63-3.el7 will be installed
    zfs: --> Processing Dependency: perl(Pod::Text) >= 3.15 for package: perl-Pod-Usage-1.63-3.el7.noarch
    zfs: --> Processing Dependency: perl-Pod-Perldoc for package: perl-Pod-Usage-1.63-3.el7.noarch
    zfs: ---> Package perl-Text-ParseWords.noarch 0:3.29-4.el7 will be installed
    zfs: ---> Package zfs-dkms.noarch 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: dkms >= 2.2.0.3 for package: zfs-dkms-0.8.5-1.el7.noarch
    zfs: --> Running transaction check
    zfs: ---> Package glibc.x86_64 0:2.17-307.el7.1 will be updated
    zfs: --> Processing Dependency: glibc = 2.17-307.el7.1 for package: glibc-common-2.17-307.el7.1.x86_64
    zfs: ---> Package glibc.x86_64 0:2.17-326.el7_9 will be an update
    zfs: ---> Package glibc-headers.x86_64 0:2.17-326.el7_9 will be installed
    zfs: --> Processing Dependency: kernel-headers >= 2.2.1 for package: glibc-headers-2.17-326.el7_9.x86_64
    zfs: --> Processing Dependency: kernel-headers for package: glibc-headers-2.17-326.el7_9.x86_64
    zfs: ---> Package perl-Pod-Perldoc.noarch 0:3.20-4.el7 will be installed
    zfs: --> Processing Dependency: perl(parent) for package: perl-Pod-Perldoc-3.20-4.el7.noarch
    zfs: --> Processing Dependency: perl(HTTP::Tiny) for package: perl-Pod-Perldoc-3.20-4.el7.noarch
    zfs: ---> Package perl-podlators.noarch 0:2.5.1-3.el7 will be installed
    zfs: ---> Package zfs-dkms.noarch 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: dkms >= 2.2.0.3 for package: zfs-dkms-0.8.5-1.el7.noarch
    zfs: --> Running transaction check
    zfs: ---> Package glibc-common.x86_64 0:2.17-307.el7.1 will be updated
    zfs: ---> Package glibc-common.x86_64 0:2.17-326.el7_9 will be an update
    zfs: ---> Package kernel-headers.x86_64 0:3.10.0-1160.88.1.el7 will be installed
    zfs: ---> Package perl-HTTP-Tiny.noarch 0:0.033-3.el7 will be installed
    zfs: ---> Package perl-parent.noarch 1:0.225-244.el7 will be installed
    zfs: ---> Package zfs-dkms.noarch 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: dkms >= 2.2.0.3 for package: zfs-dkms-0.8.5-1.el7.noarch
    zfs: --> Finished Dependency Resolution
    zfs:  You could try using --skip-broken to work around the problem
    zfs: Error: Package: zfs-dkms-0.8.5-1.el7.noarch (zfs)
    zfs:            Requires: dkms >= 2.2.0.3
    zfs:  You could try running: rpm -Va --nofiles --nodigest
    zfs: Loaded plugins: fastestmirror
    zfs: ================================== repo: zfs ===================================
    zfs: [zfs]
    zfs: async = True
    zfs: bandwidth = 0
    zfs: base_persistdir = /var/lib/yum/repos/x86_64/7
    zfs: baseurl = http://download.zfsonlinux.org/epel/7.8/x86_64/
    zfs: cache = 0
    zfs: cachedir = /var/cache/yum/x86_64/7/zfs
    zfs: check_config_file_age = True
    zfs: compare_providers_priority = 80
    zfs: cost = 1000
    zfs: deltarpm_metadata_percentage = 100
    zfs: deltarpm_percentage =
    zfs: enabled = 0
    zfs: enablegroups = True
    zfs: exclude =
    zfs: failovermethod = priority
    zfs: ftp_disable_epsv = False
    zfs: gpgcadir = /var/lib/yum/repos/x86_64/7/zfs/gpgcadir
    zfs: gpgcakey =
    zfs: gpgcheck = True
    zfs: gpgdir = /var/lib/yum/repos/x86_64/7/zfs/gpgdir
    zfs: gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
    zfs: hdrdir = /var/cache/yum/x86_64/7/zfs/headers
    zfs: http_caching = all
    zfs: includepkgs =
    zfs: ip_resolve =
    zfs: keepalive = True
    zfs: keepcache = False
    zfs: mddownloadpolicy = sqlite
    zfs: mdpolicy = group:small
    zfs: mediaid =
    zfs: metadata_expire = 604800
    zfs: metadata_expire_filter = read-only:present
    zfs: metalink =
    zfs: minrate = 0
    zfs: mirrorlist =
    zfs: mirrorlist_expire = 86400
    zfs: name = ZFS on Linux for EL7 - dkms
    zfs: old_base_cache_dir =
    zfs: password =
    zfs: persistdir = /var/lib/yum/repos/x86_64/7/zfs
    zfs: pkgdir = /var/cache/yum/x86_64/7/zfs/packages
    zfs: proxy = False
    zfs: proxy_dict =
    zfs: proxy_password =
    zfs: proxy_username =
    zfs: repo_gpgcheck = False
    zfs: retries = 10
    zfs: skip_if_unavailable = False
    zfs: ssl_check_cert_permissions = True
    zfs: sslcacert =
    zfs: sslclientcert =
    zfs: sslclientkey =
    zfs: sslverify = True
    zfs: throttle = 0
    zfs: timeout = 30.0
    zfs: ui_id = zfs/x86_64
    zfs: ui_repoid_vars = releasever,
    zfs:    basearch
    zfs: username =
    zfs: 
    zfs: Loaded plugins: fastestmirror
    zfs: ================================ repo: zfs-kmod ================================
    zfs: [zfs-kmod]
    zfs: async = True
    zfs: bandwidth = 0
    zfs: base_persistdir = /var/lib/yum/repos/x86_64/7
    zfs: baseurl = http://download.zfsonlinux.org/epel/7.8/kmod/x86_64/
    zfs: cache = 0
    zfs: cachedir = /var/cache/yum/x86_64/7/zfs-kmod
    zfs: check_config_file_age = True
    zfs: compare_providers_priority = 80
    zfs: cost = 1000
    zfs: deltarpm_metadata_percentage = 100
    zfs: deltarpm_percentage =
    zfs: enabled = 1
    zfs: enablegroups = True
    zfs: exclude =
    zfs: failovermethod = priority
    zfs: ftp_disable_epsv = False
    zfs: gpgcadir = /var/lib/yum/repos/x86_64/7/zfs-kmod/gpgcadir
    zfs: gpgcakey =
    zfs: gpgcheck = True
    zfs: gpgdir = /var/lib/yum/repos/x86_64/7/zfs-kmod/gpgdir
    zfs: gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
    zfs: hdrdir = /var/cache/yum/x86_64/7/zfs-kmod/headers
    zfs: http_caching = all
    zfs: includepkgs =
    zfs: ip_resolve =
    zfs: keepalive = True
    zfs: keepcache = False
    zfs: mddownloadpolicy = sqlite
    zfs: mdpolicy = group:small
    zfs: mediaid =
    zfs: metadata_expire = 604800
    zfs: metadata_expire_filter = read-only:present
    zfs: metalink =
    zfs: minrate = 0
    zfs: mirrorlist =
    zfs: mirrorlist_expire = 86400
    zfs: name = ZFS on Linux for EL7 - kmod
    zfs: old_base_cache_dir =
    zfs: password =
    zfs: persistdir = /var/lib/yum/repos/x86_64/7/zfs-kmod
    zfs: pkgdir = /var/cache/yum/x86_64/7/zfs-kmod/packages
    zfs: proxy = False
    zfs: proxy_dict =
    zfs: proxy_password =
    zfs: proxy_username =
    zfs: repo_gpgcheck = False
    zfs: retries = 10
    zfs: skip_if_unavailable = False
    zfs: ssl_check_cert_permissions = True
    zfs: sslcacert =
    zfs: sslclientcert =
    zfs: sslclientkey =
    zfs: sslverify = True
    zfs: throttle = 0
    zfs: timeout = 30.0
    zfs: ui_id = zfs-kmod/x86_64
    zfs: ui_repoid_vars = releasever,
    zfs:    basearch
    zfs: username =
    zfs: 
    zfs: Loaded plugins: fastestmirror
    zfs: Loading mirror speeds from cached hostfile
    zfs:  * base: mirror.mijn.host
    zfs:  * extras: mirror.mijn.host
    zfs:  * updates: ftp.tudelft.nl
    zfs: Resolving Dependencies
    zfs: --> Running transaction check
    zfs: ---> Package zfs.x86_64 0:0.8.5-1.el7 will be installed
    zfs: --> Processing Dependency: zfs-kmod = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzpool2 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzfs2 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libuutil1 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libnvpair1 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: sysstat for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzpool.so.2()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzfs_core.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libzfs.so.2()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libuutil.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Processing Dependency: libnvpair.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
    zfs: --> Running transaction check
    zfs: ---> Package kmod-zfs.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libnvpair1.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libuutil1.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libzfs2.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package libzpool2.x86_64 0:0.8.5-1.el7 will be installed
    zfs: ---> Package sysstat.x86_64 0:10.1.5-20.el7_9 will be installed
    zfs: --> Processing Dependency: libsensors.so.4()(64bit) for package: sysstat-10.1.5-20.el7_9.x86_64
    zfs: --> Running transaction check
    zfs: ---> Package lm_sensors-libs.x86_64 0:3.4.0-8.20160601gitf9185e5.el7 will be installed
    zfs: --> Finished Dependency Resolution
    zfs: 
    zfs: Dependencies Resolved
    zfs: 
    zfs: ================================================================================
    zfs:  Package           Arch     Version                            Repository  Size
    zfs: ================================================================================
    zfs: Installing:
    zfs:  zfs               x86_64   0.8.5-1.el7                        zfs-kmod   486 k
    zfs: Installing for dependencies:
    zfs:  kmod-zfs          x86_64   0.8.5-1.el7                        zfs-kmod   1.1 M
    zfs:  libnvpair1        x86_64   0.8.5-1.el7                        zfs-kmod    32 k
    zfs:  libuutil1         x86_64   0.8.5-1.el7                        zfs-kmod    26 k
    zfs:  libzfs2           x86_64   0.8.5-1.el7                        zfs-kmod   208 k
    zfs:  libzpool2         x86_64   0.8.5-1.el7                        zfs-kmod   861 k
    zfs:  lm_sensors-libs   x86_64   3.4.0-8.20160601gitf9185e5.el7     base        42 k
    zfs:  sysstat           x86_64   10.1.5-20.el7_9                    updates    315 k
    zfs: 
    zfs: Transaction Summary
    zfs: ================================================================================
    zfs: Install  1 Package (+7 Dependent packages)
    zfs: 
    zfs: Total download size: 3.0 M
    zfs: Installed size: 11 M
    zfs: Downloading packages:
    zfs: Public key for lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64.rpm is not installed
    zfs: warning: /var/cache/yum/x86_64/7/base/packages/lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    zfs: Public key for sysstat-10.1.5-20.el7_9.x86_64.rpm is not installed
    zfs: --------------------------------------------------------------------------------
    zfs: Total                                              665 kB/s | 3.0 MB  00:04
    zfs: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    zfs: Importing GPG key 0xF4A80EB5:
    zfs:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    zfs:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    zfs:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    zfs:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    zfs: Running transaction check
    zfs: Running transaction test
    zfs: Transaction test succeeded
    zfs: Running transaction
    zfs:   Installing : libnvpair1-0.8.5-1.el7.x86_64                                1/8
    zfs:   Installing : libuutil1-0.8.5-1.el7.x86_64                                 2/8
    zfs:   Installing : libzfs2-0.8.5-1.el7.x86_64                                   3/8
    zfs:   Installing : libzpool2-0.8.5-1.el7.x86_64                                 4/8
    zfs:   Installing : lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64        5/8
    zfs:   Installing : sysstat-10.1.5-20.el7_9.x86_64                               6/8
    zfs:   Installing : kmod-zfs-0.8.5-1.el7.x86_64                                  7/8
    zfs:   Installing : zfs-0.8.5-1.el7.x86_64                                       8/8
    zfs:   Verifying  : libuutil1-0.8.5-1.el7.x86_64                                 1/8
    zfs:   Verifying  : libzfs2-0.8.5-1.el7.x86_64                                   2/8
    zfs:   Verifying  : zfs-0.8.5-1.el7.x86_64                                       3/8
    zfs:   Verifying  : sysstat-10.1.5-20.el7_9.x86_64                               4/8
    zfs:   Verifying  : kmod-zfs-0.8.5-1.el7.x86_64                                  5/8
    zfs:   Verifying  : libnvpair1-0.8.5-1.el7.x86_64                                6/8
    zfs:   Verifying  : lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64        7/8
    zfs:   Verifying  : libzpool2-0.8.5-1.el7.x86_64                                 8/8
    zfs: 
    zfs: Installed:
    zfs:   zfs.x86_64 0:0.8.5-1.el7
    zfs: 
    zfs: Dependency Installed:
    zfs:   kmod-zfs.x86_64 0:0.8.5-1.el7
    zfs:   libnvpair1.x86_64 0:0.8.5-1.el7
    zfs:   libuutil1.x86_64 0:0.8.5-1.el7
    zfs:   libzfs2.x86_64 0:0.8.5-1.el7
    zfs:   libzpool2.x86_64 0:0.8.5-1.el7
    zfs:   lm_sensors-libs.x86_64 0:3.4.0-8.20160601gitf9185e5.el7
    zfs:   sysstat.x86_64 0:10.1.5-20.el7_9
    zfs: 
    zfs: Complete!
    zfs: Loaded plugins: fastestmirror
    zfs: Loading mirror speeds from cached hostfile
    zfs:  * base: mirror.mijn.host
    zfs:  * extras: mirror.mijn.host
    zfs:  * updates: ftp.tudelft.nl
    zfs: Resolving Dependencies
    zfs: --> Running transaction check
    zfs: ---> Package wget.x86_64 0:1.14-18.el7_6.1 will be installed
    zfs: --> Finished Dependency Resolution
    zfs: 
    zfs: Dependencies Resolved
    zfs: 
    zfs: ================================================================================
    zfs:  Package        Arch             Version                   Repository      Size
    zfs: ================================================================================
    zfs: Installing:
    zfs:  wget           x86_64           1.14-18.el7_6.1           base           547 k
    zfs: 
    zfs: Transaction Summary
    zfs: ================================================================================
    zfs: Install  1 Package
    zfs: 
    zfs: Total download size: 547 k
    zfs: Installed size: 2.0 M
    zfs: Downloading packages:
    zfs: Running transaction check
    zfs: Running transaction test
    zfs: Transaction test succeeded
    zfs: Running transaction
    zfs:   Installing : wget-1.14-18.el7_6.1.x86_64                                  1/1
    zfs:   Verifying  : wget-1.14-18.el7_6.1.x86_64                                  1/1
    zfs: 
    zfs: Installed:
    zfs:   wget.x86_64 0:1.14-18.el7_6.1
    zfs: 
    zfs: Complete!
    zfs: NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    zfs: sda      8:0    0   40G  0 disk
    zfs: └─sda1   8:1    0   40G  0 part /
    zfs: sdb      8:16   0  512M  0 disk
    zfs: sdc      8:32   0  512M  0 disk
    zfs: sdd      8:48   0  512M  0 disk
    zfs: sde      8:64   0  512M  0 disk
    zfs: sdf      8:80   0  512M  0 disk
    zfs: sdg      8:96   0  512M  0 disk
    zfs: sdh      8:112  0  512M  0 disk
    zfs: sdi      8:128  0  512M  0 disk
    zfs: NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
    zfs: mir1   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    zfs: mir2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    zfs: mir3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    zfs: mir4   480M    88K   480M        -         -     0%     0%  1.00x    ONLINE  -
```

</details>