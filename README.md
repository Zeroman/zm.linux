[zm system](http://51feel.info) — Simple linux system for work
==================================================

总览
-----------------------------------------
zm 软件是基于debian系统开发, 类似livecd, 将整个系统压缩为squashfs文件，配合unionfs实现读写。主要有几大功能：
1. 一条命令安装系统，安装介质可是硬盘，u盘，光盘等，整个系统就4个文件，kernel，initrd，root.sfs，home.sfs。
2. 支持生成差分文件，差分文件也被压缩为squashfs文件。
3. 默认顶层差分存放在内存，所以启动和常用软件操作速度很快。
4. 自带备份系统，将工作目录备份为squashfs文件，备份文件也支持差分。
Debian的stable kernel支持aufs，unstable默认已经不支持aufs， overlayfs的/proc/self的bug没有解决，不推荐在unstale使用overlay备份系统，


分区
-----------------------------------------
系统根据磁盘卷标自动识别并启动。
分区软件可以用gparted或者gnome-disks。
支持lvm分区并建议使用。
文件系统推荐为ext4。
系统分区的卷标为sfsroot，建议20G。
可选work分区的卷标为work，用于挂载/work，工作磁盘分区，越大越好。
可选swap分区的卷标为swap，建议4G。
可选备份分区的卷标为backup，用于存放备份的项目，建议200G。

```bash
hdd_dev=/dev/sdb

dd if=/dev/zero of=$hdd_dev bs=1k count=64
parted -s -a optimal $hdd_dev mklabel gpt
parted -s -a optimal $hdd_dev mkpart lvm 2048s 100%
parted -s -a optimal $hdd_dev toggle 1 lvm
pvcreate /dev/sdb1

pvcreate /dev/sdb
vgcreate zm /dev/sdb
lvcreate -L 50G -n sfsroot zm
lvcreate -L 4G -n swap zm
lvcreate -L 400G -n backup zm
lvcreate -l $(pvdisplay -c | awk -F: '{print $10}') -n work zm

mkfs.ext4 -L zm-backup /dev/mapper/zm-backup
mkfs.ext4 -L zm-work /dev/mapper/zm-work
mkfs.ext4 -L zm-sfsroot /dev/mapper/zm-sfsroot
mkswap -L swap /dev/mapper/zm-swap
```

2. 记住系统分区的设备路径，比如/dev/sdb1, 运行如下命令:
```bash
sudo zm --install-system /dev/sdb1 --arch amd64 --zm-user user --kernel-params zm_save=yes
```

3. 备份系统
```bash
sudo zm -u 
```

4. 制作分支
```bash
sudo zm -b 
```
 

