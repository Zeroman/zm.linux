


出现此错误，需要让磁盘开始到首个分区的开始位置更大
'''
grub-install: warning: your core.img is unusually large.  It won't fit in the embedding area.
grub-install: error: embedding is not possible, but this is required for RAID and LVM install.
'''

```
开机启动的目标是 default.target，默认链接到 graphical.target （大致相当于原来的运行级别5）。可以通过内核参数更改默认运行级别：
    systemd.unit=multi-user.target （大致相当于级别3）
    systemd.unit=rescue.target （大致相当于级别1）
```

测试efi
```
qemu-system-x86_64 -m 512 -hda /dev/sdc --bios /usr/share/ovmf/x64/OVMF_CODE.fd
```

https://wiki.archlinux.org/index.php/Secure_Boot


https://wiki.gentoo.org/wiki/Efibootmgr
efibootmgr -c -d /dev/sda -p 2 -L "Gentoo" -l "\efi\boot\bootx64.efi"
efibootmgr -c -d /dev/sda -p 2 -L "Win10Setup" -l "\bootmgr.efi"

#查看
efibootmgr -v
#删除
efibootmgr -b 0001 -B
#创建
efibootmgr -c -w -L "HDD GRUB" -d /dev/sda -p 2 -l \\EFI\\GRUB\\bootx64.efi
#修改boot 顺序
efibootmgr -o 0012,0010,0011,000F,000D,000C,000B
