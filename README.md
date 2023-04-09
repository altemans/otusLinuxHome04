# Home 04 ZFS
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

