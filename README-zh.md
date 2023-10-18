[zm system](http://51feel.info) — Simple linux system for work
==================================================

总览
-----------------------------------------
zm 软件是基于debian系统开发, 类似livecd, 将整个系统压缩为squashfs文件，配合unionfs实现读写。主要有几大功能：
1. 一条命令安装系统，安装介质可是硬盘，u盘，光盘等，整个系统就4个文件，kernel，initrd，root.sfs，home.sfs。
2. 支持生成差分文件，差分文件也被压缩为squashfs文件。
3. 默认顶层差分存放在内存，所以启动和常用软件操作速度很快。
4. 自带备份系统，将工作目录备份为squashfs文件，备份文件也支持差分。
5. 直接生成虚拟机需要的disk镜像。
Debian的stable kernel支持aufs，unstable默认已经不支持aufs， overlayfs的/proc/self的bug没有解决，不推荐在unstable使用overlay备份系统，


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
lvm自动分区命令如下：
```bash
zm --create-part name=zm:parts=/dev/sda1:sfsroot=20G:union=20G:backup=100G:swap=4G:work=-
# 将/dv/sda3, /dev/sda4, /dev/sdb1分区格式成lvm2分区，创建name为zm的vg
# sfsroot 20G， 用于存放系统
# backup 100G，备份系统使用，建议使用一半的剩余空间
# swap 4G，虚拟内存
# work 分区，平时工作分区，最后一个分区参数可以为-，表示使用剩余的所有空间
# 也支持这种参数格式 sfsroot=20%FREE union=10%VG 具体如何使用请参考源代码
zm --create-part name=zm:parts=/dev/sda3,/dev/sda4,/dev/sdb1:sfsroot=20G:union=20G:backup=100G:swap=4G:work=-
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
 

