#!/bin/sh 

PREREQS=""
prereqs()
{
    echo $PREREQS
}

case $1 in
    prereqs)
        exit 0
        ;;
esac

if [ -e /scripts/functions ];then
    . /scripts/functions
fi

os_name=""
if uname -a | grep "Debian" > /dev/null 2>&1;then
    os_name="debian"
fi
if uname -a | grep "Arch" > /dev/null 2>&1;then
    os_name="archlinux"
fi


sfs_part=""
union_part=""
home_part=""
work_part=""
backup_part=""

sfs_show=false
union_show=true

root_mem_size=0
home_mem_size=0

zm_dir=""
zm_name="zm"
zm_kernel=""
zm_save="yes"
zm_debug=false

root_file=""
home_file=""
union_min_size=1024

#mount path
sfs_part_mpath=/media/sfsroot
sfs_mpath=/media/sfs
union_mpath=/media/union
sfs_root_mpath=$sfs_mpath/root
sfs_home_mpath=$sfs_mpath/home
union_root_mpath=""
union_home_mpath=""
union_clean_file=.union.fs.clean

case "$os_name" in
    debian)
        new_root=/root
        ;;
    archlinux)
        new_root=/new_root
        ;;
esac
root_mpath=/
home_mpath=/home
work_mpath=/work
backup_mpath=/media/backup

union_max_branch=8
cpu_counts=$(cat /proc/cpuinfo | grep "processor" | wc -l)
KERNEL_VERSION=$(uname -r | awk  -F '-' 'BEGIN{OFS="."}{print $1}' | awk  -F '.' 'BEGIN{OFS="."}{print $1,$2,$3}')

get_linux_kernel_code()  
{  
    #expr $(VERSION) \* 65536 + 0$(PATCHLEVEL) \* 256 + 0$(SUBLEVEL));  
    VERSION=`echo $1 | awk  -F '.' 'BEGIN{OFS="."}{print $1}'`  
    PATCHLEVEL=`echo $1 | awk  -F '.' 'BEGIN{OFS="."}{print $2}'`  
    SUBLEVEL=`echo $1 | awk  -F '.' 'BEGIN{OFS="."}{print $3}'`  
    #echo $VERSION  
    #echo $PATCHLEVEL  
    #echo $SUBLEVEL  
    KERNEL_CODE=`expr $VERSION \* 65536 + 0$PATCHLEVEL \* 256 + 0$SUBLEVEL`  
    return $KERNEL_CODE  
} 

debug_var()
{
    var=$1
    eval value='$'$var
    printf "  %-15s : %-s\n" $var $value
}

print_param_info()
{
    debug_var sfs_part
    debug_var union_part
    debug_var home_part
    debug_var work_part
    debug_var backup_part
    debug_var root_mem_size
    debug_var home_mem_size
    debug_var union_min_size
    debug_var root_file
    debug_var home_file
}

err_exit()
{
    print_param_info
    panic $@
}

print_msg()
{
    echo $@ > /dev/console
}

goto_shell()
{
    print_msg "$@"
    print_msg "Goto shell, and prees ctrl + d to continue."

    case "$os_name" in
        debian)
            PS1='[zm:initramfs] ' /bin/sh -i </dev/console >/dev/console 2>&1
            true
            ;;
        archlinux)
            launch_interactive_shell
            ;;
    esac
}

get_filesize_mb()
{
    test -e "$1" || err_exit "$1 is no exist!"
    fileSizeB=`stat -c %s $1`
    fileSizeKB=`expr $fileSizeB / 1024`
    fileSizeMB=`expr $fileSizeKB / 1024`
    echo $fileSizeMB
}

get_mem_freesize_mb()
{
    all_free_size=$(free -m | grep Mem | awk '{print $4}')
    expr $all_free_size - 512
}

get_freesize_dir_mb()
{
    size_mb=$(df -mP $1 | sed -n '2p' | awk '{print $4}')
    echo ${size_mb}
}

get_freesize_path()
{
    min_size=$1; shift
    all_path=$@

    free_path=""
    for path in $all_path
    do
        if [ "$(get_freesize_dir_mb $path)" -gt $min_size ];then
            free_path=$path
        fi
        if [ -n "$free_path" ];then
            break
        fi
    done
    echo $free_path
}

mount_storage()
{
    mount_src=$1
    mount_point=$2
    if [ -b "$mount_src" ];then
        print_msg "Check filesystem on $mount_src ..."
        checkfs $mount_src $mount_point
    fi
    print_msg "Mounting $mount_src on $mount_point ..."
    mkdir -p -m 0755 $mount_point
    mount $mount_src $mount_point || err_exit "mount $@ error"
}

is_mounted()
{
    if cat /proc/mounts | grep " $1 " > /dev/null 2>&1;then
        return 0
    fi
    return 1
}

mount_move()
{
    old_mpath=$1
    new_mpath=$2/$1

    if ! is_mounted $old_mpath;then
        return 0
    fi

    mkdir -p -m 0755 $new_mpath
    mount -n -o move $old_mpath $new_mpath || err_exit "mount move $old_mpath $new_mpath error"
}

init_params()
{
    for x in $(cat /proc/cmdline); do
        case $x in
            sfs_part=*)
                sfs_part=${x#sfs_part=}
                ;;
            union_part=*)
                union_part=${x#union_part=}
                ;;
            root_mem_size=*)
                root_mem_size=${x#root_mem_size=}
                ;;
            home_mem_size=*)
                home_mem_size=${x#home_mem_size=}
                ;;
            zm_name=*)
                zm_name=${x#zm_name=}
                ;;
            zm_dir=*)
                zm_dir=${x#zm_dir=}
                ;;
            home_part=*)
                home_part=${x#home_part=}
                ;;
            work_part=*)
                work_part=${x#work_part=}
                ;;
            backup_part=*)
                backup_part=${x#backup_part=}
                ;;
            BOOT_IMAGE=*)
                zm_kernel=${x#BOOT_IMAGE=}
                ;;
            zm_save=*)
                zm_save=${x#zm_save=}
                ;;
            debug)
                zm_debug=true
                set -x
                ;;
        esac
    done

    case $sfs_part in 
        cdrom|/dev/sr*)
            if [ $sfs_part = "cdrom" ];then
                sfs_part=/dev/sr0
            fi
            ;;
        *)
            ;;
    esac

    in_virtual_machine="no"
    if cat /proc/cpuinfo | grep 'model name' | grep -i -E 'kvm|qemu|virtual' > /dev/null;then
        in_virtual_machine="yes"
    fi
    all_mem_size=$(free -g | grep Mem | awk '{print $2}')

    if [ -z "$zm_kernel" ];then
        err_exit "Not find kernel param in cmdline."
    fi

    if [ -z "$zm_dir" ];then
        zm_dir=$(dirname $zm_kernel)
    fi

    free_mem_size=$(get_mem_freesize_mb) 
    if [ "$free_mem_size" -gt "$union_min_size" ];then
        test $root_mem_size = 0 && root_mem_size=$free_mem_size
        test $home_mem_size = 0 && home_mem_size=$free_mem_size
    fi

    if which lvm > /dev/null;then
        lvm vgchange -aly --ignorelockingfailure
    fi
}

wait_part()
{
    wait_part=$1
    wait_time=$2

    test -z "$wait_time" && wait_time=5
    for i in `seq 1 $wait_time`;do
        if [ -b $wait_part ];then
            return 0
        fi
        sleep 1
    done
    return 1
}

get_zm_part()
{
    local name=$1
    local part=""

    part="/dev/${zm_name}/$name"
    if [ -b "$part" ];then
        echo $part
        return 0
    fi

    part="/dev/disk/by-label/${zm_name}-${name}"
    if [ -b "$part" ];then
        echo $part
        return 0
    fi

    part="/dev/disk/by-label/${name}"
    if [ -b "$part" ];then
        echo $part
        return 0
    fi

    echo ""
    return 0
}

init_sfs()
{
    modprobe isofs 
    modprobe ext2 
    modprobe ext3 
    modprobe ext4 
    modprobe squashfs
    # modprobe vfat 
    # modprobe ntfs

    test -n "$sfs_part" && sfs_part=$(resolve_device $sfs_part)
    test -n "$union_part" && union_part=$(resolve_device $union_part)
    test -n "$home_part" && home_part=$(resolve_device $home_part)
    test -n "$work_part" && work_part=$(resolve_device $work_part)
    test -n "$backup_part" && backup_part=$(resolve_device $backup_part)

    test -n "$sfs_part" || sfs_part="/dev/${zm_name}/sfsroot"

    wait_part $sfs_part 5 || sfs_part="/dev/${zm_name}/sfsroot"
    wait_part $sfs_part 1 || sfs_part="/dev/disk/by-label/${zm_name}-sfsroot"
    wait_part $sfs_part 1 || sfs_part="/dev/disk/by-label/sfsroot"
    wait_part $sfs_part 1 || err_exit "no sfs partiton"

    mount_storage $sfs_part $sfs_part_mpath

    root_sfs="$zm_dir/root.sfs"
    home_sfs="$zm_dir/home.sfs"
    root_file=$(readlink -f $sfs_part_mpath/${root_sfs} || true)
    home_file=$(readlink -f $sfs_part_mpath/${home_sfs} || true)
    test -e "$root_file" || err_exit "Not found root sfs file!"

    test -b "$home_part" || home_part="$(get_zm_part 'home')"
    test -b "$home_part" && mount_storage $home_part $home_mpath

    test -b "$work_part" || work_part="$(get_zm_part 'work')"
    test -b "$work_part" && mount_storage $work_part $work_mpath

    test -b "$backup_part" || backup_part="$(get_zm_part 'backup')"
    test -b "$backup_part" && mount_storage $backup_part $backup_mpath

    test -b "$union_part" || union_part="$(get_zm_part 'union')"
    test -b "$union_part" && mount_storage $union_part $union_mpath

    test -b "$swap_part" || swap_part="$(get_zm_part 'swap')"
    test -b "$swap_part" && swapon $swap_part

    if is_mounted $union_mpath && test "$zm_save" = "yes";then
        union_root_mpath=$union_mpath/root
        union_home_mpath=$union_mpath/home
        mkdir -p -m 0755 $union_root_mpath
        mkdir -p -m 0755 $union_home_mpath
    fi
    # touch ${union_root_mpath}/$union_clean_file
    # touch ${union_home_mpath}/$union_clean_file
}

# mount_with_aufs root /media/sfsroot/linux/amd64/zm /media/sfs /media/union_fs/ /root/
__mount_with_aufs()
{
    sfsname="$1"
    sfsdir="$2"
    sfsmountdir=$3
    upperdir="$4"
    mountdir="$5"

    test -d "$upperdir" || err_exit "upperdir: $upperdir is not found!"
    test -d "$mountdir" || err_exit "mountdir: $mountdir is not found!"

    sfsfile=$(readlink -f "${sfsdir}/${sfsname}.sfs")
    test -f "$sfsfile" || err_exit "sfsfile: ${sfsdir}/${sfsname}.sfs is not found!"

    if [ -e "${upperdir}/$union_clean_file" ];then
        rm -rf ${upperdir}/{*,.[!.]*,..?*}
    fi

    sfsmpath=$sfsmountdir/$sfsname
    mount_storage $sfsfile $sfsmpath
    mount -t aufs -o br:$upperdir none $mountdir
    mount -t aufs -o remount,udba=none,append:${sfsmpath}=rr none $mountdir
    for branch in $(seq 1 $union_max_branch)
    do
        if [ -e "${sfsfile}.${branch}" ];then
            mount_storage ${sfsfile}.${branch} ${sfsmpath}.${branch}
            mount -t aufs -o remount,udba=none,add:1:${sfsmpath}.${branch}=ro+wh none $mountdir
            continue
        fi
        break
    done
}

__mount_with_overlay()
{
    sfsname="$1"
    sfsdir="$2"
    sfsmountdir=$3
    upperdir="$4"
    mountdir="$5"


    test -d "$upperdir" || err_exit "upperdir: $upperdir is not found!"
    test -d "$mountdir" || err_exit "mountdir: $mountdir is not found!"

    sfsfile=$(readlink -f "${sfsdir}/${sfsname}.sfs")
    test -f "$sfsfile" || err_exit "sfsfile: ${sfsdir}/${sfsname}.sfs is not found!"

    if [ -e "${upperdir}/$union_clean_file" ];then
        rm -rf ${upperdir}/{*,.[!.]*,..?*}
    fi

    lowerdir=""
    set_lowerdir()
    {
        if [ -z "$lowerdir" ];then
            lowerdir=$@
        else
            lowerdir=$@:${lowerdir}
        fi
    }

    sfsmpath=$sfsmountdir/$sfsname
    mount_storage $sfsfile $sfsmpath
    set_lowerdir ${sfsmpath}
    for branch in $(seq 1 $union_max_branch)
    do
        if [ -e "${sfsfile}.${branch}" ];then
            mount_storage ${sfsfile}.${branch} ${sfsmpath}.${branch}
            set_lowerdir ${sfsmpath}.${branch}
            continue
        fi
        break
    done

    debug_var $lowerdir

    mkdir -p -m 0755 $upperdir/upper
    mkdir -p -m 0755 $upperdir/work
    options="lowerdir=$lowerdir,upperdir=$upperdir/upper,workdir=$upperdir/work"
    mount -t overlay -o $options overlay $mountdir
}

mount_union()
{
    if modprobe overlay > /dev/null 2>&1;then
        __mount_with_overlay $@
    elif modprobe aufs > /dev/null 2>&1;then
        __mount_with_aufs $@
    else
        echo "no support union filesystem."
        return 1
    fi
}

mount_root()
{
    if [ -z "$union_root_mpath" ];then
        test $root_mem_size -gt $union_min_size || err_exit "root_mem_size less len union_min_size"
        union_root_mpath=$union_mpath/root
        mkdir -p -m 0755 $union_root_mpath
        mount -t tmpfs -o mode=755,size=${root_mem_size}m none $union_root_mpath 
    fi
    mount_union root $sfs_part_mpath/$zm_dir $sfs_mpath $union_root_mpath ${new_root}/$root_mpath
}

mount_home()
{
    if is_mounted $home_mpath;then
        return 0
    fi

    if [ ! -e "$home_file" ];then
        goto_shell "home file is not found, maybe start with error, please check again." 
    fi

    if [ -z "$union_home_mpath" ];then
        test $home_mem_size -gt $union_min_size || err_exit "home_mem_size less then union_min_size"
        union_home_mpath=$union_mpath/home
        mkdir -p -m 0755 $union_home_mpath
        mount -t tmpfs -o mode=755,size=${home_mem_size}m none $union_home_mpath
    fi

    mkdir -p -m 0755 $home_mpath
    mount_union home $sfs_part_mpath/$zm_dir $sfs_mpath $union_home_mpath $home_mpath
}

swap_file() 
{
    chmod 600 $1
    mkswap $1
    swapon $1
}

move_to_newroot()
{
    mount_move $sfs_part_mpath ${new_root}
    mount_move $home_mpath ${new_root}
    mount_move $work_mpath ${new_root}
    mount_move $union_mpath ${new_root}
    mount_move $backup_mpath ${new_root}

    if $union_show;then
        mount_move $union_root_mpath ${new_root}
        mount_move $union_home_mpath ${new_root}
    fi

    if $sfs_show;then
        mount_move $sfs_root_mpath ${new_root}
        for branch in $(seq 1 $union_max_branch)
        do
            if [ -e "${root_file}.${branch}" ];then
                mount_move ${sfs_root_mpath}.${branch} ${new_root}
                continue
            fi
            break
        done

        mount_move $sfs_home_mpath ${new_root}
        for branch in $(seq 1 $union_max_branch)
        do
            if [ -e "${home_file}.${branch}" ];then
                mount_move ${sfs_home_mpath}.${branch} ${new_root}
                continue
            fi
            break
        done
    fi
}

sfsroot_main()
{
    # umask 0077
    init_params
    init_sfs
    mount_root
    mount_home
    move_to_newroot
    # umask 0022

    test "$os_name" = "archlinux" && mount_handler='true'

    if $zm_debug;then
        print_param_info
        print_msg "please input y/n for continue."
        read choice
        if [ "$choice" != "y" ];then
            goto_shell
        fi
    fi
}

# for archlinux
run_hook()
{
    sfsroot_main
}

case "$os_name" in
    debian)
        sfsroot_main
        ;;
    archlinux)
        ;;
esac


