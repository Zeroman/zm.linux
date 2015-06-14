安装到其他机器方法如下：

1. 分区，其他机器的硬盘需要分出2个区，一个区装系统，一个区用于挂载/work,分区软件可以用gparted或者gnome-disks, 分别格式化为ext4文件系统, 系统分区的卷标改为sfsroot，work分区的卷标改为work

2. 记住系统分区的设备路径，比如/dev/sdb1, 运行如下命令:
    sudo zm --install-system /dev/sdb1 --arch amd64 --zm-user user --kernel-params zm_save=yes

3. 备份系统
    sudo zm -u 

4. 制作分支
    sudo zm -b 
 

