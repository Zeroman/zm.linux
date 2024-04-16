#!/bin/bash - 

# Zeroman Yang (51feel@gmail.com)
# 11/09/2015


_add_softs_common()
{
    add_soft base-devel

    add_soft tzdata
    add_soft pkgfile

    add_soft grub efibootmgr efitools

    # add_soft console-tools 
    # add_soft console-common 
    add_soft gettext
    add_soft intltool

    add_soft sudo
    add_soft autojump
    add_soft bash-completion
    add_soft busybox
    add_soft tree
    # add_soft finger
    add_soft pinfo procinfo htop iotop less
    # add_soft minicom ckermit lrzsz 
    add_soft vbindiff dhex hexer colordiff
    add_soft enca convmv #mrename
    # add_soft genisoimage
    add_soft ntp
    # search like ack - ag rg
    add_soft the_silver_searcher ripgrep

    # add_soft alsa-base 
    add_soft alsa-utils alsa-tools
    add_soft pulseaudio pulseaudio-alsa

    add_soft linux-headers
    add_soft mesa-demos
    add_soft libvdpau-va-gl
    add_soft libva-intel-driver
    # add_soft firmware-linux-free firmware-linux-nonfree 
    # add_soft firmware-atheros firmware-brcm80211 firmware-ralink firmware-realtek zd1211-firmware
    # add_soft cpufrequtils 
    add_soft cpupower
    add_soft fbset usbutils
    add_soft upower 
    add_soft smartmontools dmidecode
    # add_soft lm-sensors 
    # add_soft libva1
    # add_soft acpi-support 
    # add_soft acpi 

    # add_soft sendemail sendip

    add_soft pwgen
    # add_soft dia #dia2code
    add_soft keepassx

    # for multi thread download
    add_soft axel

    #for fs img
    # add_soft kpartx bximage

    add_soft iputils
    # add_soft arping
    add_soft arp-scan tcpdump
    # add_soft wireshark # 网络流量分析器
    # add_soft iptraf #局域网ip监控
    add_soft nethogs #监视每个进程使用的网络带宽
    add_soft iftop #监视网络带宽
    add_soft dnsutils
    add_soft traceroute
    add_soft openbsd-netcat
    # add_soft namebench 

    add_soft lsb-release 
    #add_soft gksu
    add_soft imagemagick feh gpicview geeqie #pinta
    add_soft terminator guake #mate-terminal sakura
    add_soft networkmanager nm-connection-editor network-manager-applet
    # add_soft wicd wicd-gtk

    add_soft bison flex 
    add_soft bc cpio

    # add_soft cjk-latex
    # add_soft latex-cjk-chinese
    # add_soft texlive-generic-recommended
    # add_soft texlive-latexextra
    # add_soft texlive-bin texlive-core texlive-langchinese
    # add_soft texinfo
    # add_soft lmodern fonts-lmodern

    add_soft fzf
    add_soft trash-cli
    add_soft gvim 
    # add_soft clewn #vifm
    # add_soft vim-syntax-go vim-syntax-gtk
    add_soft xclip xsel python-neovim neovim
    add_soft ctags cscope 
    # add_soft flawfinder locate cgvg cutils icheck cccc cproto
    # add_soft cppcheck 
    # add_soft mtd-utils 
    # add_soft u-boot-tools
    # add_soft splint 
    add_soft astyle highlight source-highlight #indent
    add_soft sloccount cloc
    # add_soft gdb valgrind #mutextrace 
    add_soft autoconf automake libtool make 
    add_soft cmake 
    # add_soft scons 
    add_soft fakeroot
    add_soft ccache
    # add_soft avahi-daemon distcc 
    add_soft expect
    add_soft dos2unix exfat-utils ntfs-3g
    add_soft graphviz dot2tex xdot 
    # add_soft asymptote
    # add_soft grc #for colouriser command

    add_soft curl 

    add_soft meld 
    add_soft evince poppler-data 
    # add_soft apvlv #impressive
    # add_soft mypaint
    add_soft netpbm gv plotutils # for umlgraph

    add_soft parallel
    add_soft zip bzip2 unzip lzop p7zip
    add_soft unrar xarchiver

    add_soft ttf-bitstream-vera 
    add_soft ttf-arphic-ukai ttf-arphic-uming
    add_soft wqy-microhei wqy-zenhei wqy-microhei-lite
    add_soft adobe-source-han-sans-cn-fonts
    add_soft ttf-ubuntu-font-family 
    add_soft ttf-droid
    add_soft ttf-liberation
    add_soft opendesktop-fonts 

    add_soft txt2tags html2text wv
    # add_soft pandoc
    # add_soft doxygen
    add_soft lftp 
    #add_soft ncftp
    # add_soft tftpd-hpa 
    # add_soft vsftpd
    # add_soft nfs-kernel-server openbsd-inetd 
    # add_soft samba #use docker
    add_soft smbclient cifs-utils 
    add_soft sshfs sshpass
    # add_soft qstardict sdcv 
    #add_soft workrave

    add_soft zenity dialog 

    # json tools:json_reformat
    add_soft yajl
    add_soft jq

    add_soft git perl-term-readkey perl-mime-tools
    add_soft tig 
    add_soft subversion #mercurial bzr 

    add_soft gparted xfsprogs dmraid parted #jfsutils

    add_soft hdparm

    add_soft rsync
    # add_soft handbrake handbrake-cli # for convert iso to mp4
    # add_soft mplayer mencoder
    # add_soft mpg123 
    add_soft strace ltrace lsof lshw

    add_soft qt5-tools
    #add_soft qtcreator

    add_soft code

    add_soft tk
    add_soft python python-docs
    add_soft python-imaging python-paramiko 
    add_soft python-dateutil
    add_soft python-requests
    #add_soft python-pyqt4 
    add_soft python-pyqt5
    add_soft python-pylint
    add_soft python-pillow # for python image
    add_soft ipython ipython2
    add_soft python-pip
    add_soft python-jedi #Awesome autocompletion for python
    add_soft python-ipdb python2-ipdb
    add_soft python-pudb python2-pudb
    add_soft python-prettytable
    add_soft yapf
    add_soft python-rope

    #for math
    add_soft python-scipy python-matplotlib python-numpy
    add_soft python-pandas python-numexpr python-pandas-datareader python-bottleneck
    add_soft python-sqlalchemy 
    add_soft python-redis
    add_soft python-pymongo

    add_soft ruby

    #manpages-zh 
    add_soft man-pages
    #add_soft linux-manpages

    # for czwx
    # add_soft pptp-linux pptpd xl2tpd
    # add_soft libexosip2-dev libssl-dev libasound2-dev libcairo2-dev

    # add_soft cairo-dock

    # for jre
    add_soft maven
    add_soft gradle
    add_soft apache-ant
    add_soft jdk8-openjdk 
    add_soft java-openjfx
    add_soft visualvm
    # add_soft proguard
    # add_soft intellij-idea-community-edition 
    # add_soft eclipse-java

    # add_soft virtualbox virtualbox-guest-iso

    add_soft qemu
    add_soft ovmf #UEFI firmware for qemu
    add_soft freerdp
    add_soft bridge-utils 

    #for windows xrdp
    # add_soft xrdp

    add_soft mplayer
    #add_soft smplayer
    add_soft ffmpeg 
    # add_soft vlc 
    # add_soft audacity


    #add_soft bumblebee primus bbswitch

    add_soft sqlite
    add_soft sqlitebrowser
    add_soft mysql-workbench
    add_soft mariadb-clients
    add_soft redis
    add_soft dbeaver

    # add_soft bashdb 
    # add_soft mini-httpd

    add_soft udisks2 
    # add_soft udiskie

    add_soft docker
    add_soft docker-compose
    add_soft docker-machine
    add_soft python-docker
    add_soft python-colorama

    # add_soft redsocks

    # for android or 32bit
    add_soft android-tools #adb mkbootimg fastboot
    add_soft android-udev
    #add_soft repo

    # add_soft gcc-multilib 
    # add_soft lib32-zlib lib32-ncurses lib32-readline
    # add_soft lib32-gcc-libs lib32-libstdc++5
    add_soft jad jadx # for decompile apk

    # add_soft clang # for ycm

    #add_soft go go-tools

    add_soft mtpfs gvfs-mtp gvfs-afc 

    # for mono develop
    # add_soft mono mono-tools mono-addins
    # add_soft monodevelop
    # add_soft xsp

    # for nodejs
    add_soft npm 
    add_soft yarn
    add_soft electron
    add_soft eslint gulp uglify-js 
    add_soft browserify

    # for emscripten
    # add_soft emscripten
    # add_soft llvm

    # for lua
    # add_soft luajit tolua++

    # for sjjz
    add_soft wkhtmltopdf
    add_soft python-certifi
}

_add_softs_common_i386()
{
    echo ""
    # add_soft wine
}

_add_softs_common_amd64()
{
    echo ""
    # add_soft wine32-development wine64-development
}

_add_softs_gui()
{
    # add_soft rapidsvn
    add_soft kdesvn

    add_soft xorg  
    add_soft xorg-xinit xterm
    add_soft xdotool #for x11 automation
    # add_soft xserver-xorg-video-qxl
    add_soft xorg-drivers
    #add_soft slim 
    # add_soft gimp

    add_soft obmenu obconf python-xdg
    add_soft geany gsimplecal leafpad gucharmap
    add_soft gnome-themes-standard
    add_soft human-icon-theme hicolor-icon-theme gnome-icon-theme
    add_soft gnome-keyring
    #add_soft xfce4-notifyd 
    # add_soft notify-osd #libnotify-bin

    # add_soft atom

    add_soft fcitx fcitx-configtool
    add_soft fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5
    # add_soft ibus-gtk ibus-gtk3 ibus-qt4 sunpinyin-data ibus-sunpinyin

    # add_soft synaptic

    # add_soft lxde-gtk3
    add_soft lxqt compton lxdm-gtk3
     #add_soft parcellite # clipit
    #add_soft planner
    add_soft xtrlock 
    add_soft numlockx

    # add_soft xfce4-panel xfce4-cpugraph-plugin xfce4-diskperf-plugin 
    # add_soft xfce4-sensors-plugin xfce4-battery-plugin
    # add_soft thunar thunar-volman thunar-archive-plugin 

    add_soft spice-gtk3
    add_soft tigervnc

    add_soft chromium 
    add_soft firefox ttf-fira-mono ttf-fira-sans
    add_soft firefox-i18n-en-us firefox-i18n-zh-cn
    add_soft flashplugin
    # add_soft openfetion pidgin
    # add_soft google-chrome-stable #google-chrome-beta
    # add_soft icedove icedove-l10n-zh-cn
    # add_soft icedove-l10n-zh-cn

    # add_soft xbindkeys
    # add_soft gtk-recordmydesktop
    add_soft gnome-system-log gnome-disk-utility
    add_soft gnome-screenshot #shutter

    # add_soft devhelp
    # add_soft fontforge

    # add_soft gnumeric abiword

    # for compile spice-gtk
    add_soft gtk-engines
    # add_soft gtk-doc
    add_soft spice-protocol

    # add_soft xmind

    #for ftp client with gui
    #add_soft filezilla
    #add_soft libreoffice-fresh
    # add_soft openoffice
    add_soft libreoffice-still

    #yaourt -S --noconfirm 
    # add soft form custom repo
    add_soft package-query
    add_soft yaourt
    add_soft cgvg 
    add_soft apparix
    add_soft zeal-git
    add_soft ttf-vlgothic
    add_soft grc
    add_soft ta-lib
    
    #add_soft visual-studio-code-bin
    # add_aur_soft google-chrome
    # add_aur_soft python-kivy
    # add_aur_soft perl-text-csv


    # repo_dir=/work/cache/pacman/repo
    # touch $repo_dir/custom.db
    # yaourt -Syu
    # pacman -Q judge installed? 

}

zm_add_softs() 
{
    zm_user_command _add_softs_common
    zm_user_command _add_softs_common_${zm_arch}
    zm_user_command _add_softs_gui
}

_setup_locale()
{
    $SUDO sed -i 's/#\(zh_CN.*$\)/\1/g' /etc/locale.gen
    $SUDO sed -i 's/#\(en_US.*$\)/\1/g' /etc/locale.gen
    $SUDO locale-gen
    $SUDO localectl set-locale LANG=en_US.UTF-8
}

_setup_service()
{
    $SUDO systemctl disable cron.service || true
    $SUDO systemctl disable redsocks || true

    $SUDO systemctl enable lxdm || true
    $SUDO systemctl enable docker || true
    $SUDO systemctl enable smbd || true
    $SUDO systemctl enable nmbd || true
    $SUDO systemctl enable sshd || true
    $SUDO systemctl enable NetworkManager || true
}

_setup_host()
{
    if [ -e $zm_user_dir/hosts ];then
        sed -i 's/.*ajax.googleapis.com.*/125.88.190.68	ajax.googleapis.com #ajax.useso.com/g' $zm_user_dir/hosts
        sed -i 's/.*fonts.googleapis.com.*/125.88.190.68	fonts.googleapis.com #fonts.useso.com/g' $zm_user_dir/hosts
        diff $zm_user_dir/hosts /etc/hosts > /dev/null || $SUDO install -D $zm_user_dir/hosts /etc/hosts
    fi
}

_setup_udev_rules()
{
    for rule in $(ls $zm_user_dir/*.rules)
    do
        $SUDO install -m 0644  -D $rule -t /etc/udev/rules.d/
    done
}

_setup_network()
{
    if [ -d $zm_user_dir/system-connections/ ];then
        $SUDO install -m 0600 -D $zm_user_dir/system-connections/* -t /etc/NetworkManager/system-connections/
    fi
}

_setup_docker()
{
    graph_opt='--graph /work/docker/data -s overlay'
    mirror_opt='--registry-mirror=https://docker.mirrors.ustc.edu.cn'
    $SUDO sed -i 's#--graph .*$##g' /usr/lib/systemd/system/docker.service 
    $SUDO sed -i "s#\(ExecStart.*$\)#\1 $graph_opt $mirror_opt#g" /usr/lib/systemd/system/docker.service 
    $SUDO systemctl daemon-reload
    mkdir -p $zm_user_home/.docker
    echo '{
    "detachKeys": "ctrl-q,q"
}
' > $zm_user_home/.docker/config.json
    $SUDO systemctl restart docker || true
}

_setup_lxdm()
{
    if [ -f  $zm_user_dir/lxdm.conf ];then
        $SUDO install -D $zm_user_dir/lxdm.conf /var/lib/lxdm/lxdm.conf
    fi
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

_setup_npm()
{
    mkdir -p /work/node/npm/cache
    $SUDO npm set cache /work/node/npm/cache
    #$SUDO npm -g install instant-markdown-d
    # $SUDO npm -g install multi-file-swagger

    # for javascript
    $SUDO npm -g install esmangle #压缩js
    $SUDO npm -g install js-beautify
    $SUDO npm -g install eslint-plugin-vue
}

_setup_env()
{
    # for start gtk3 application with warning
    if ! grep NO_AT_BRIDGE /etc/environment;then
        echo "export NO_AT_BRIDGE=1" | $SUDO tee -a /etc/environment
    fi

    $SUDO ln -sf /usr/lib/libncursesw.so /usr/lib/libtinfo.so.5 
}

_setup_time()
{
    sudo timedatectl set-ntp true
    # sudo ntpd -u ntp:ntp
    # timedatectl 
    # systemctl status systemd-timesyncd
}

_setup_sudo()
{
    # for zm backup mount 

    #$SUDO sed -i 's$^#includedir /etc/sudoers.d$includedir /etc/sudoers.d$g' /etc/sudoers
    if ! $SUDO cat /etc/sudoers.d/zm | grep mount;then
        echo "$zm_user    ALL=(ALL) ALL" | $SUDO tee /etc/sudoers.d/zm
        echo "$zm_user    ALL=NOPASSWD: /usr/sbin/mount" | $SUDO tee -a /etc/sudoers.d/zm
        echo "$zm_user    ALL=NOPASSWD: /usr/sbin/umount" | $SUDO tee -a /etc/sudoers.d/zm
        echo "$zm_user    ALL=NOPASSWD: /usr/sbin/mkdir" | $SUDO tee -a /etc/sudoers.d/zm
        echo "$zm_user    ALL=NOPASSWD: /usr/sbin/rmdir" | $SUDO tee -a /etc/sudoers.d/zm
        echo "$zm_user    ALL=NOPASSWD: /usr/sbin/chown" | $SUDO tee -a /etc/sudoers.d/zm
    fi
}

_pip_install()
{
    #$SUDO easy_install certifi
    #pip install -U docker
    #pip install -U docker-py
    #pip install -U docker-compose 
    $SUDO pip install mycli #for mysql
    #$SUDO pip install pgcli #for mysql
    $SUDO pip install TA-Lib
    $SUDO pip install py-term
    #$SUDO pip install -U wharfee #for docker command, conflict with docker
    #$SUDO pip install -U rqalpha 

    $SUDO pip install python-binance
}

zm_setup()
{
    need_root

    zm_setup_tzdata 'Asia' 'Hong_Kong'
    zm_setup_user

    _setup_udev_rules
    _setup_locale
    _setup_host
    _setup_network
    _setup_docker
    _setup_lxdm
    _setup_sudo
    # _setup_samba #use samba in docker now
    _setup_service
    _setup_npm
    _setup_env
    _setup_time

    _pip_install

    zm_set_hostname 'Zeroman'

    pkgfile --update
}

