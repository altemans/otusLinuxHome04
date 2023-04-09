 #install zfs repo
yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
#import gpg key 
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
#install DKMS style packages for correct work ZFS
yum install -y epel-release kernel-devel zfs
#change ZFS repo
yum-config-manager --disable zfs
yum-config-manager --enable zfs-kmod
yum install -y zfs
#Add kernel module zfs
modprobe zfs
#install wget
yum install -y wget

lsblk
chmod +x ./get_disks_no_root.sh
readarray -t arr < <( ./get_disks_no_root.sh )

sudo zpool create mir1 mirror /dev/${arr[0]} /dev/${arr[1]}
sudo zpool create mir2 mirror /dev/${arr[2]} /dev/${arr[3]}
sudo zpool create mir3 mirror /dev/${arr[4]} /dev/${arr[5]}
sudo zpool create mir4 mirror /dev/${arr[6]} /dev/${arr[7]}
zpool list