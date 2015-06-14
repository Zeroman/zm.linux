#!/bin/bash 

_add_softs_common()
{
    # add_soft console-tools 
    add_soft gettext
    add_soft sudo
    add_soft console-common 
    add_soft zsh autojump
    add_soft bash-completion
    add_soft busybox
    add_soft tree
    add_soft finger
    add_soft pinfo procinfo htop iotop less
    add_soft minicom ckermit lrzsz 
    add_soft vbindiff dhex hexer
    add_soft enca convmv mrename
    add_soft genisoimage
    add_soft ntp
    add_soft trash-cli

    add_soft dpkg-dev

    add_soft alsa-base alsa-utils alsa-tools
    add_soft pulseaudio

    add_soft firmware-linux-free firmware-linux-nonfree 
    add_soft firmware-atheros firmware-brcm80211 firmware-ralink firmware-realtek zd1211-firmware
    add_soft cpufrequtils fbset usbutils
    add_soft upower lm-sensors 
    add_soft libva1
    add_soft acpi-support acpi

    add_soft sendemail sendip

    add_soft dia dia2code
    add_soft keepassx

    add_soft apt-file synaptic
    add_soft rcconf 

    #for fs img
    add_soft kpartx bximage

    add_soft arping arp-scan tcpdump
    add_soft wireshark # 网络流量分析器
    add_soft iptraf #局域网ip监控
    add_soft nethogs #监视每个进程使用的网络带宽
    add_soft iftop #监视网络带宽
    add_soft dnsutils
    # add_soft namebench 

    add_soft lsb-release gksu
    add_soft imagemagick feh gpicview geeqie gimp pinta
    add_soft terminator #mate-terminal sakura
    add_soft network-manager network-manager-gnome gnome-keyring
    add_soft notify-osd libnotify-bin
    # add_soft wicd wicd-gtk

    add_soft bison flex 

    add_soft cjk-latex
    add_soft latex-cjk-chinese
    add_soft texlive-generic-recommended
    add_soft texlive-xetex
    add_soft texinfo

    add_soft vifm
    # add_soft vim-syntax-go vim-syntax-gtk
    add_soft exuberant-ctags cscope flawfinder lcov locate
    add_soft cgvg cproto cutils icheck cccc cppcheck cproto
    add_soft mtd-utils 
    add_soft u-boot-tools
    add_soft astyle indent highlight source-highlight
    add_soft valgrind mutextrace 
    add_soft splint splint-data
    add_soft sloccount
    add_soft gcc g++ gdb gdbserver
    #add_soft libstdc++6-4.7-doc
    #add_soft libstdc++6-4.7-dbg
    add_soft autoconf automake colormake cmake libtool make 
    add_soft scons scons-doc
    add_soft fakeroot
    add_soft avahi-daemon distcc ccache
    add_soft expect
    add_soft dos2unix exfat-utils
    add_soft graphviz dot2tex xdot asymptote
    add_soft grc

    add_soft csstidy curl 

    add_soft meld dirdiff 
    add_soft evince-gtk poppler-data apvlv impressive
    add_soft mypaint
    add_soft netpbm gv plotutils # for umlgraph

    add_soft parallel
    add_soft bzip2 unzip lzop
    add_soft rar unrar xarchiver
    add_soft p7zip-full p7zip-rar

    add_soft fonts-vlgothic 
    add_soft ttf-wqy-microhei ttf-wqy-zenhei ttf-bitstream-vera xfonts-wqy 
    add_soft fonts-arphic-ukai fonts-arphic-uming
    add_soft fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp 

    add_soft txt2tags html2text wv tidy
    add_soft doxygen-gui doxygen-latex docbook 
    add_soft tftp tftpd-hpa lftp ncftp proftpd-basic telnet
    # add_soft vsftpd
    add_soft nfs-kernel-server openbsd-inetd 
    add_soft samba samba-common-bin smbclient cifs-utils 
    add_soft openssh-server ssh sshfs
    add_soft stardict sdcv stardict-plugin stardict-plugin-espeak stardict-plugin-festival
    add_soft apparix
    #add_soft workrave

    add_soft zenity dialog whiptail ssft 

    add_soft git git-svn git-cvs git-email git-gui git-man git-cola tig
    add_soft subversion cvs mercurial #bzr tkcvs 
    add_soft rapidsvn

    add_soft gparted xfsprogs reiserfsprogs reiser4progs jfsutils dmraid parted libparted-dev libparted-i18n

    add_soft realpath rsync
    # add_soft mplayer mencoder
    add_soft mpg123 mp3rename
    add_soft sqlite sqlitebrowser
    add_soft strace ltrace lsof lshw

    add_soft python python-doc python-dev pylint
    add_soft python-imaging python-paramiko python-serial 
    add_soft python-openssl libnss3-tools
    add_soft python-requests
    add_soft python-pip python3-pip
    add_soft python-tk python3-tk
    add_soft python-gevent #for goagent

    add_soft ruby

    add_soft manpages-dev 
    #manpages-zh 
    add_soft manpages-posix manpages-posix-dev
    add_soft libc6-dev
    add_soft libreadline-dev
    add_soft libgtk2.0-dev libgtk-3-dev
    add_soft libncurses5-dev
    add_soft libgtest-dev

    # for czwx
    # add_soft pptp-linux pptpd xl2tpd
    # add_soft libexosip2-dev libssl-dev libasound2-dev libcairo2-dev

    # add_soft cairo-dock

    # for jre
    add_soft default-jre default-jdk ant
    # add_soft openjdk-8-jre openjdk-8-jdk

    # for multi thread download
    add_soft axel

    #add_soft virtualbox virtualbox-qt virtualbox-dkms virtualbox-guest-additions-iso

    add_soft qemu qemu-kvm rdesktop spice-client spice-client-gtk
    add_soft bridge-utils libvirt-bin uml-utilities
    #add_soft clang libclang-dev

    #for windows xrdp
    # add_soft xrdp

    # for coco2d-x
    add_soft libx11-dev libxmu-dev libglu1-mesa-dev libgl2ps-dev  
    add_soft libxi-dev libzip-dev libfontconfig1-dev libjbig-dev
}

_add_softs_i386_stable()
{
    echo ""
}

_add_softs_common_stable() 
{
    echo ""
}

_add_softs_common_unstable() 
{
    # add_soft mini-httpd
    # add_soft bashdb

    add_soft udisks2 
    add_soft fonts-lmodern
    add_soft clang-3.7

    add_soft jq #json tools
    add_soft python-termcolor

    add_soft ffmpeg 
    add_soft smplayer
    add_soft vlc browser-plugin-vlc libvlc-dev

    add_soft compton

    add_soft qt4-default 
    # add_soft qt5-default
    add_soft qtbase5-dev
}

_add_softs_common_i386()
{
    true
}

_add_softs_common_amd64()
{
    add_soft libjai-core-java libjai-imageio-core-java

    # for mutl arch i386
    dpkg --add-architecture i386
    #for build android
    add_soft gcc-multilib libc6-i386  libc6-dev-i386 lib32z1 lib32stdc++-4.9-dev
    add_soft xsltproc zip gperf libswitch-perl
}

_add_gui_soft()
{
    add_soft xorg xinit 
    add_soft lightdm 
    # add_soft xserver-xorg-video-qxl
    #add_soft slim 

    add_soft openbox
    add_soft obmenu obconf human-icon-theme python-xdg
    add_soft geany gsimplecal grun leafpad gucharmap

    add_soft fcitx fcitx-m17n fcitx-pinyin fcitx-module-cloudpinyin fcitx-config-gtk fcitx-ui-light fcitx-ui-classic
    add_soft fcitx-frontend-all fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt4 fcitx-frontend-qt5
    # add_soft ibus-gtk ibus-gtk3 ibus-qt4 sunpinyin-data ibus-sunpinyin
    # add_soft im-config

    # add_soft lxde 
    add_soft lxsession #lxpolkit 
    add_soft lxpanel lxtask lxappearance clipit
    add_soft arandr lxrandr
    add_soft oxygencursors
    add_soft gtk2-engines gtk2-engines-murrine gtk2-engines-wonderland
    add_soft pcmanfm gvfs-backends gvfs-fuse

    # add_soft google-chrome-stable #google-chrome-beta
    add_soft iceweasel iceweasel-l10n-zh-cn
    add_soft xul-ext-adblock-plus xul-ext-flashblock xul-ext-downthemall
    # add_soft openfetion pidgin
    # add_soft icedove icedove-l10n-zh-cn
    # add_soft icedove-l10n-zh-cn

    add_soft xtrlock
    add_soft xbindkeys xbindkeys-config  autokey-gtk
    add_soft audacity
    add_soft gtk-recordmydesktop
    add_soft gnome-system-log gnome-disk-utility gnome-system-tools
    add_soft gnome-screenshot #shutter
    add_soft gtg #gnome task 

    add_soft vim-gtk 
    add_soft devhelp
    add_soft fontforge

    add_soft libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-l10n-zh-cn
    add_soft gnumeric abiword

    add_soft qtcreator
    add_soft qt4-dev-tools qt4-doc libqt4-sql-sqlite
    add_soft libqt4-opengl-dev libqtwebkit-dev qt4-designer
    # add_soft qt4-demos 
    add_soft python-qt4
}


zm_add_softs() 
{
    zm_user_command _add_softs_common
    zm_user_command _add_softs_common_${deb_arch}
    zm_user_command _add_softs_common_${deb_ver}
    zm_user_command _add_softs_${deb_arch}_${deb_ver}
    zm_user_command _add_gui_soft
}

_setup_user()
{
    if ! grep 8888 /etc/group > /dev/null;then
        groupadd -g 8888 $zm_user 
        useradd -m -s /bin/bash -u 8888 -g 8888 $zm_user
        # useradd -m -s /bin/zsh -u 8888 -g 8888 $zm_user
        echo $zm_user:'resu' | chpasswd
        echo root:'toor' | chpasswd
        zm_add_groups floppy disk dialout audio video plugdev netdev sudo kvm vboxusers
        echo "
        $zm_user    ALL=NOPASSWD: /bin/mount
        $zm_user    ALL=NOPASSWD: /bin/umount
        " > /dev/null
        # " > /etc/sudoers.d/$zm_user.mount
    fi
    if [ -e /work ];then
        chown $zm_user:$zm_user /work #-R    
        chown $zm_user:$zm_user $(cat /etc/passwd | grep $zm_user | awk -F: '{print $6}') #-R
    fi
}

_setup_service()
{
    _setup_nfs
    _setup_tftpd

    # rcconf --off mini-httpd
    rcconf --off proftpd
    rcconf --off nfs-kernel-server
    rcconf --off tftpd-hpa
    rcconf --off openbsd-inetd
    rcconf --off distcc
}

_setup_samba()
{
    if [ -e $zm_user_dir/smb.conf ];then
        cp -fv $zm_user_dir/smb.conf /etc/samba/smb.conf
        # pdbedit -L $zm_user 
        passwd="<<<$zm_user>>>"
        _add_samba_user $zm_user $passwd
        # service samba restart
    fi
}

_setup_flash()
{
    #dpkg-reconfigure flashplugin-nonfree

    apt-get install flashplugin-nonfree
    update-flashplugin-nonfree --install

    # apt-get install pepperflashplugin-nonfree #for chromium
    # update-pepperflashplugin-nonfree --install
}

zm_setup()
{
    # no nouveau
    # echo "blacklist nouveau" > /etc/modprobe.d/nouveau-blacklist.conf

    zm_setup_default_locales

    zm_setup_sh bash
    zm_setup_tzdata 'Asia' 'Hong_Kong'

    _setup_user
    _setup_samba
    _setup_service
    _setup_flash
}

_setup_tftpd()
{
    if [ -e /etc/default/tftpd-hpa ];then
        sed -i 's#TFTP_DIRECTORY=.*#TFTP_DIRECTORY="/work/tftp"#g' /etc/default/tftpd-hpa
    else
        dpkg-reconfigure tftpd-hpa
    fi
}

_setup_nfs()
{
    mkdir -p /work/nfs
    # nfs的root目录确保都是755，否则出现权限不够
    chmod 755 /work/
    nfs_dir=/work/nfs/
    chmod 755 $nfs_dir
    echo "$nfs_dir *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)" > /etc/exports
    # /etc/init.d/nfs-kernel-server restart
}

