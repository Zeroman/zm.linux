#!/bin/bash - 

zm_user_init() 
{
    deb_ver=unstable
}

zm_add_softs()
{
    #for shell

    # add_soft console-tools 
    add_soft console-common 
    add_soft bashdb bash-completion
    add_soft htop iotop less
    add_soft ntp
    add_soft trash-cli

    add_soft cpufrequtils 
    add_soft acpi-support acpi

    add_soft rcconf 
    add_soft at

    add_soft iptraf #局域网ip监控
    add_soft nethogs #监视每个进程使用的网络带宽
    add_soft iftop #监视网络带宽
    # add_soft namebench 

    add_soft exuberant-ctags cscope flawfinder lcov locate
    add_soft cgvg cproto cutils icheck cccc cppcheck cproto
    add_soft astyle indent highlight source-highlight
    add_soft valgrind mutextrace 
    add_soft splint splint-data
    add_soft sloccount
    add_soft gcc g++ gdb gdbserver
    #add_soft libstdc++6-4.7-doc
    #add_soft libstdc++6-4.7-dbg
    add_soft autoconf automake colormake cmake libtool make
    add_soft fakeroot
    add_soft avahi-daemon distcc ccache
    add_soft expect
    add_soft dos2unix
    add_soft graphviz dot2tex xdot

    add_soft parallel
    add_soft bzip2 unzip
    add_soft rar unrar xarchiver
    add_soft p7zip-full p7zip-rar

    add_soft txt2tags 
    add_soft samba samba-common-bin smbclient cifs-utils 
    add_soft openssh-server ssh sshfs
    add_soft apparix

    add_soft zenity dialog whiptail ssft 

    add_soft subversion git-all cvs mercurial tkcvs tig bzr
    add_soft gitolite3
    add_soft sendemail

    add_soft realpath rsync
    add_soft sqlite
    add_soft strace ltrace lsof lshw

    add_soft python python-doc python-dev python-pip
    add_soft python-openssl libnss3-tools
    add_soft python-urllib3 python-requests

    add_soft axel

    add_soft quota
    add_soft openjdk-7-jdk

    #for zendao
    #add_soft mysql-server php5 php5-mysql apache2

    if [ "$deb_arch" == "amd64" ];then
        # for mutl arch i386
        dpkg --add-architecture i386
        #for build android
        add_soft bison flex u-boot-tools
        add_soft xsltproc  gcc-multilib libc6-i386
        add_soft libc6-dev-i386 libstdc++6:i386 lib32z1 libncurses5:i386
        add_soft gnupg flex bison gperf build-essential 
        add_soft zip curl libc6-dev libreadline6-dev:i386 g++-multilib tofrodos python-markdown libxml2-utils 
    fi

}

zm_setup_apt()
{
    > /etc/apt/sources.list
    echo "deb $apt_url/debian $deb_ver main non-free contrib" >> /etc/apt/sources.list
    echo "deb-src $apt_url/debian $deb_ver main non-free contrib" >> /etc/apt/sources.list

    apt-get update
}

_setup_users()
{
    echo root:"<toor>" | chpasswd

    users='yangzm litao wuyt jizhf duanpf'
    for user in $users
    do
        if ! grep 5555 /etc/group;then
            groupadd -g 5555 user
        fi
        if ! grep $user /etc/passwd;then
            useradd -m -s /bin/bash -g 5555 $user
            echo $user:"${user}2014" | chpasswd
        fi
        cp -fv $zm_user_dir/.bashrc /home/$user
        cp -fv $zm_user_dir/.vimrc /home/$user
    done

    mkdir -p /root/.ssh
    cat $zm_user_dir/server.pub > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys

}

_setup_samba()
{
    # config samba
    if [ -e $zm_user_dir/smb.conf ];then
        diff $zm_user_dir/smb.conf /etc/samba/smb.conf && return
        cp -fv $zm_user_dir/smb.conf /etc/samba/smb.conf
        users='yangzm litao wuyt jizhf duanpf'
        for user in $users
        do
            _add_samba_user $user "${user}2014"
        done
        /etc/init.d/samba  restart
    fi
}

_setup_env()
{
    cp -fv $zm_user_dir/.bashrc /root/
    cp -fv $zm_user_dir/.vimrc  /root/
    cp -fv $zm_user_dir/.profile  /root/
    cp -fv $zm_user_dir/rc.local /etc/rc.local
}

_setup_net()
{
    cp -fv $zm_user_dir/interfaces /etc/network/interfaces
    cp -fv $zm_user_dir/resolv.conf /etc/resolv.conf
    service networking restart
}

_setup_rsync()
{
    cp -fv $zm_user_dir/rsync.conf /etc/
    # echo "rsync --daemon --config=rsync.conf" >> /etc/rc.local
    # rsync -avP server::sdk/temp .
}

zm_setup()
{
    zm_setup_sh bash
    zm_setup_tzdata 'Asia' 'Hong_Kong'
    zm_setup_default_locales

    _setup_users
    _setup_samba
    _setup_env
    _setup_net
    _setup_rsync
}

