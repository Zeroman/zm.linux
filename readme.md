


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
