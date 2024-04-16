#!/bin/bash 

debian_release=${os_name#*.}

zm_user_init()
{
    true
}

_add_softs_common()
{
    # add_soft console-tools 
    add_soft gettext
    add_soft intltool

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
    add_soft trash-cli
    add_soft ntp

    add_soft dpkg-dev

    add_soft alsa-utils alsa-tools
    add_soft pulseaudio

    add_soft firmware-linux-free firmware-linux-nonfree 
    add_soft firmware-atheros firmware-brcm80211 firmware-realtek firmware-zd1211 firmware-misc-nonfree
    add_soft cpufrequtils fbset usbutils
    add_soft upower lm-sensors 
    add_soft libva2
    add_soft acpi-support acpi

    add_soft sendemail sendip

    add_soft dia dia2code
    add_soft keepassx

    add_soft apt-file 
    add_soft rcconf 

    # for multi thread download
    add_soft axel

    #for fs img
    add_soft kpartx bximage

    add_soft arping arp-scan tcpdump
    add_soft wireshark # 网络流量分析器
    add_soft iptraf #局域网ip监控
    add_soft nethogs #监视每个进程使用的网络带宽
    add_soft iftop #监视网络带宽
    add_soft dnsutils
    # add_soft namebench 

    add_soft gimp
    add_soft mypaint
    add_soft lsb-release
    add_soft imagemagick feh gpicview geeqie #pinta
    add_soft terminator mate-terminal #sakura
    add_soft network-manager network-manager-gnome gnome-keyring
    add_soft notify-osd libnotify-bin
    # add_soft wicd wicd-gtk

    add_soft bison flex 

    # add_soft cjk-latex
    # add_soft latex-cjk-chinese
    # add_soft texlive-generic-recommended
    # add_soft texlive-xetex
    # add_soft texinfo
    # add_soft lmodern fonts-lmodern

    add_soft vifm
    # add_soft vim-syntax-go vim-syntax-gtk
    add_soft exuberant-ctags cscope flawfinder lcov locate
    add_soft cgvg cutils icheck cccc cppcheck cproto
    add_soft mtd-utils 
    add_soft u-boot-tools
    add_soft astyle indent highlight source-highlight
    add_soft valgrind
    add_soft splint splint-data
    add_soft sloccount
    add_soft gcc g++ gdb gdbserver
    add_soft autoconf automake colormake libtool make 
    add_soft cmake cmake-curses-gui cmake-qt-gui
    add_soft scons scons-doc
    add_soft fakeroot
    add_soft ccache
    # add_soft avahi-daemon distcc 
    add_soft expect
    add_soft dos2unix exfatprogs
    add_soft graphviz dot2tex xdot asymptote
    add_soft grc

    add_soft csstidy curl 

    add_soft meld dirdiff 
    add_soft evince poppler-data apvlv impressive
    add_soft netpbm gv plotutils # for umlgraph

    add_soft parallel
    add_soft bzip2 unzip lzop
    add_soft rar unrar xarchiver
    add_soft p7zip-full p7zip-rar

    add_soft fonts-vlgothic 
    add_soft ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy 
    add_soft ttf-bitstream-vera 
    add_soft fonts-arphic-ukai fonts-arphic-uming
    add_soft fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp 
    add_soft fonts-droid-fallback

    add_soft txt2tags html2text wv tidy
    add_soft doxygen-gui doxygen-latex docbook 
    add_soft tftp lftp ncftp telnet

    # move this services to docker
    # add_soft proftpd-basic
    # add_soft tftpd-hpa 
    # add_soft vsftpd
    # add_soft nfs-kernel-server openbsd-inetd 

    add_soft samba samba-common-bin smbclient cifs-utils 
    add_soft openssh-server ssh sshfs
    add_soft stardict sdcv stardict-plugin stardict-plugin-espeak stardict-plugin-festival
    add_soft apparix
    #add_soft workrave

    add_soft zenity dialog whiptail ssft 

    add_soft git git-svn git-cvs git-email git-gui git-man git-cola tig
    add_soft subversion cvs mercurial #bzr tkcvs 

    add_soft gparted xfsprogs reiserfsprogs reiser4progs jfsutils dmraid parted libparted-dev libparted-i18n

    add_soft rsync
    # add_soft mplayer mencoder
    add_soft mpg123 mp3rename
    add_soft sqlite3
    add_soft sqlitebrowser
    add_soft strace ltrace lsof lshw

    add_soft python3 python3-doc python3-dev pylint
    add_soft python3-paramiko python3-serial 
    add_soft python3-openssl libnss3-tools
    add_soft python3-requests
    add_soft python3-pip
    add_soft python3-tk
    add_soft python3-gevent #for goagent
    add_soft python3-pygments

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

    # add_soft virtualbox virtualbox-qt virtualbox-dkms virtualbox-guest-additions-iso

    add_soft qemu-utils qemu-kvm rdesktop spice-client-gtk aqemu
    add_soft bridge-utils
    add_soft clang libclang-dev

    # for compile objc
    # add_soft gobjc gobjc++ gnustep libgnustep-base-dev gnustep-make

    #for mono develop
    #add_soft mono-complete monodevelop mono-xsp 

    #for windows xrdp
    # add_soft xrdp
    add_soft xtightvncviewer

    # for godot
    add_soft libssl-dev libasound2-dev

    add_soft libgl1-mesa-dri libglapi-mesa libgles1 libgles2-mesa libglu1-mesa
    add_soft mesa-utils mesa-utils-extra    #for glxinfo

    # for cocos2d-x
    # add_soft libx11-dev libxmu-dev libglu1-mesa-dev libgl2ps-dev  
    # add_soft libxi-dev libzip-dev libfontconfig1-dev libjbig-dev
    # add_soft xorg-dev libtinyxml2-dev libtiff5-dev libwebsockets-dev
    # add_soft chipmunk-dev libwebp-dev libglew-dev libsqlite3-dev
    # add_soft libgmp-dev libgmpxx4ldbl libgnutlsxx28 libp11-kit-dev libtasn1-6-dev libtasn1-doc nettle-dev
    # add_soft libcurl4-gnutls-dev libgmp-dev libgmpxx4ldbl libgnutls28-dev libgnutlsxx28 libp11-kit-dev libtasn1-6-dev libtasn1-doc nettle-dev
    # add_soft libglfw3-dev #for >= cocos2d 3.0
    # add_soft libglfw-dev #for < cocos2d 3.0

    add_soft docker.io

    # for gfw proxy
    # add_soft geoip-bin

    add_soft smplayer
    # add_soft vlc browser-plugin-vlc libvlc-dev

    # maybe not ok
    # add_soft vdpau-va-driver vdpauinfo
    # add_soft nvidia-vdpau-driver mesa-vdpau-drivers 

    add_soft bumblebee-nvidia nvidia-settings primus

    # add_soft wx-common
    # add_soft libwxgtk2.8-dev libwxgtk3.0-dev
    # add_soft wx2.8-doc wx2.8-examples wx2.8-headers wx2.8-i18n python-wxgtk2.8
}

_add_softs_i386_stable()
{
    echo ""
}

_add_softs_common_stable() 
{
    echo ""
    add_soft libstdc++-12-doc
    add_soft libstdc++6-12-dbg

    # add_soft rapidsvn
    # add_soft audacity
}

_add_softs_common_unstable() 
{
    add_soft libstdc++-5-doc
    add_soft libstdc++6-5-dbg

    add_soft bashdb 
    # add_soft mini-httpd

    add_soft udisks2 
    #add_soft clang-3.7 libclang-3.7-dev #for ycp: ./install.sh --system-libclang --clang-completer

    add_soft jq #json tools
    add_soft python-termcolor

    add_soft ffmpeg 

}

_add_softs_common_i386()
{
    add_soft wine
}

_add_softs_common_amd64()
{
    # add_soft wine32-development wine64-development

    # add_soft mingw32
    # add_soft libjai-core-java libjai-imageio-core-java

    #for build android
    add_soft gcc-multilib g++-multilib
    add_soft libc6-i386 lib32stdc++6
    add_soft libc6-dev-i386 lib32z1 #libstdc++-4.9-dev
    add_soft xsltproc zip gperf libswitch-perl

}

_add_softs_stable_amd64()
{
    echo ""
}

_add_softs_gui()
{
    add_soft xorg xinit 
    # add_soft xserver-xorg-video-qxl
    #add_soft slim 

    add_soft compton
    add_soft openbox
    add_soft obconf python3-xdg
    add_soft geany gsimplecal grun l3afpad gucharmap
    # add_soft human-icon-theme 

    add_soft fcitx fcitx-m17n fcitx-pinyin fcitx-module-cloudpinyin fcitx-config-gtk fcitx-ui-light fcitx-ui-classic
    add_soft fcitx-frontend-all fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt5 fcitx-frontend-qt5
    # add_soft ibus-gtk ibus-gtk3 ibus-qt5 sunpinyin-data ibus-sunpinyin
    add_soft im-config

    # add_soft synaptic

    # add_soft lightdm 
    # add_soft lxde 
    add_soft lxdm
    add_soft lxsession #lxpolkit 
    add_soft lxpanel lxtask lxappearance clipit
    add_soft arandr lxrandr
    add_soft oxygencursors
    add_soft gtk2-engines gtk2-engines-murrine
    add_soft pcmanfm gvfs-backends gvfs-fuse
    # add_soft planner

    # add_soft xfce4-panel xfce4-cpugraph-plugin xfce4-diskperf-plugin 
    # add_soft xfce4-sensors-plugin xfce4-battery-plugin
    # add_soft thunar thunar-volman thunar-archive-plugin 

    add_soft chromium 
    # add_soft iceweasel iceweasel-l10n-zh-cn
    # add_soft iceweasel-vimperator 
    # add_soft openfetion pidgin
    # add_soft google-chrome-stable #google-chrome-beta
    # add_soft icedove icedove-l10n-zh-cn
    # add_soft icedove-l10n-zh-cn

    add_soft xtrlock
    add_soft xbindkeys xbindkeys-config
    add_soft autokey-gtk
    add_soft recordmydesktop
    add_soft gnome-system-log gnome-disk-utility gnome-system-tools
    add_soft gnome-screenshot #shutter
    add_soft gtg #gnome task 

    add_soft vim-gtk3
    add_soft devhelp
    # add_soft fontforge

    # add_soft gnumeric abiword
    add_soft libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-l10n-zh-cn

    add_soft qtchooser
    #add_soft libqt5-dev qt5-dev-tools
    #add_soft libqt5-sql-sqlite libqtwebkit4 python-qt5 libqt5-opengl-dev 
    #add_soft qt5-designer
    add_soft qtbase5-dev qt5-qmake qtbase5-dev-tools libqt5opengl5-dev libqt5sql5-sqlite python3-pyqt5
    add_soft qtcreator 
    # add_soft qt5-doc qt5-doc
    # add_soft qt5-demos 

    add_soft khelpcenter #for all man,info...
    add_soft filezilla # graphical ftp client

    # for mind map
    #add_soft vym
    add_soft corkscrew redsocks
}


zm_add_softs() 
{
    zm_user_command _add_softs_common
    zm_user_command _add_softs_common_${zm_arch}
    zm_user_command _add_softs_common_${debian_release}
    zm_user_command _add_softs_${debian_release}_${zm_arch}
    zm_user_command _add_softs_gui
}

_setup_host()
{
    if [ -e $zm_user_dir/hosts ];then
        diff $zm_user_dir/hosts /etc/hosts > /dev/null || $SUDO install -D $zm_user_dir/hosts /etc/hosts
    fi
}

_setup_network()
{
    if [ -d $zm_user_dir/system-connections/ ];then
        $SUDO install -m 0600 -D $zm_user_dir/system-connections/* -t /etc/NetworkManager/system-connections/
    fi
}

___zm_setup_apt()
{
    > /etc/apt/sources.list
    # src_url=http://mirrors.ustc.edu.cn
    src_url=http://free.nchc.org.tw
    echo "deb $src_url/debian $debian_release main non-free contrib" >> /etc/apt/sources.list
    echo "deb-src $src_url/debian $debian_release main non-free contrib" >> /etc/apt/sources.list
    echo "deb $src_url/debian-multimedia $debian_release main non-free" >> /etc/apt/sources.list
    echo "deb-src $src_url/debian-multimedia $debian_release main non-free" >> /etc/apt/sources.list
    #squeeze-proposed-updates
    #cp -fv $zm_user_dir/google-chrome.list /etc/apt/sources.list.d/

    $APTGET update
    $APTGET install -y --force-yes deb-multimedia-keyring
    $APTGET update
}

_setup_user()
{
    if ! grep 8888 /etc/group > /dev/null;then
        groupadd -g 8888 $zm_user 
        useradd -m -s /bin/bash -u 8888 -g 8888 $zm_user
        # useradd -m -s /bin/zsh -u 8888 -g 8888 $zm_user
        echo $zm_user:'afj;' | chpasswd
        echo root:'afj;' | chpasswd
        zm_add_groups floppy disk dialout audio video plugdev netdev sudo kvm docker vboxusers bumblebee
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

_setup_docker()
{
    $SUDO sed -i 's@#DOCKER_OPTS=.*@DOCKER_OPTS="--graph=/work/docker/data"@g' /etc/default/docker
}

_setup_font()
{
    local fontconfigdir=$(eval echo ~$zm_user)/.config/fontconfig/
    mkdir -p $fontconfigdir
    $CP $zm_user_dir/fonts.conf $fontconfigdir
}

_setup_fcitx()
{
    rsync -avP $zm_user_dir/*.mb /usr/share/fcitx/pinyin/
}

_setup_service()
{
    echo ""
    # _setup_nfs
    # _setup_tftpd
    $SUDO systemctl disable cron.service || true
    $SUDO systemctl disable redsocks || true
    # systemctl disable inetd.service || true
    # rcconf --off openbsd-inetd || true

    # rcconf --off mini-httpd
    # rcconf --off distcc
    # rcconf --off proftpd || true
    # rcconf --off nfs-kernel-server || true
    # rcconf --off tftpd-hpa
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

_setup_google_chrome()
{
    if dpkg-query -f '${db:Status-Status}\n' -W google-chrome-stable 2>&1 | grep ^installed > /dev/null 2>&1;then
        return
    fi

    if [ -e /work/cache/download/chrome/google-chrome-stable_current_${zm_arch}.deb ];then
        $SUDO touch /etc/default/google-chrome
        dpkg -i /work/cache/download/chrome/google-chrome-stable_current_${zm_arch}.deb || true
        $APTGET -f install
        # rm -f /etc/apt/sources.list.d/google-chrome.list
    fi
}

_setup_virtualbox()
{
    local kernel_ver=$(get_kernel_ver)
    local cur_kernel_ver=$(uname -r)

	_new_install_vbox() 
{
    local pkgname="virtualbox-5.0"
    if is_installed $pkgname;then
        return
    fi

    echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib" \
        | $SUDO tee /etc/apt/sources.list.d/virtualbox.list > /dev/null
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    $APTGET update
    $APTGET install $pkgname
    return
}

    if [ "$cur_kernel_ver" != "$kernel_ver" ];then
        echo "Can't install virtualbox, $kernel_ver != $cur_kernel_ver"
        return 0
    fi

    local moddir=/lib/modules/$(uname -r)
    if [ -e $moddir/misc/vboxdrv.ko -o -e $moddir/updates/dkms/vboxdrv.ko ];then
        return 0
    fi

    local vbox_ver=5.0.10
    local vbox_dir=/work/cache/download/VirtualBox-$vbox_ver

    if [ -d "$vbox_dir" ];then
        if [ "$zm_arch" = "amd64" ];then
            $SUDO sh $vbox_dir/VirtualBox-$vbox_ver-*-Linux_amd64.run
        else
            $SUDO sh $vbox_dir/VirtualBox-$vbox_ver-*-Linux_x86.run
        fi
        $SUDO VBoxManage extpack install $vbox_dir/Oracle_VM_VirtualBox_Extension_Pack-$vbox_ver.vbox-extpack || true
    fi
}

zm_setup()
{
    need_root

    # no nouveau
    echo "blacklist nouveau" | $SUDO tee /etc/modprobe.d/nouveau-blacklist.conf

    zm_setup_default_locales

    zm_setup_sh bash
    zm_setup_tzdata 'Asia' 'Hong_Kong'

    _setup_service
    _setup_host
    _setup_network
    _setup_google_chrome
    _setup_virtualbox
    _setup_docker
    _setup_user
    _setup_samba
    _setup_font
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

