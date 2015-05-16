### for bak

_SUDO=`which sudo`

zm_work_dir=/work
zm_backup_mpath=/media/backup
zm_backup_old_dir=${zm_backup_mpath}/old
zm_backup_dir=/media/bak
zm_sfs_dir=/media/sfs
zm_bak_max_branch=5

__compress_dir_to_sfs()
{
    src_dir=$1
    dst_sfs=$2

    opts="-comp lzo -wildcards"
    if [ -e $src_dir/.sfs_ignore ];then
        opts+=" -ef $src_dir/.sfs_ignore"
    fi
    $_SUDO mksquashfs $src_dir $dst_sfs $opts
}

__check_bak_env() 
{
    mount | grep $zm_backup_mpath > /dev/null 2>&1 || return 1

    bak_name="$1"

    test -z "$bak_name" && return 1

    bak_path=$(readlink -e $bak_name)
    if [ ! -d $bak_path ];then
        echo "$bak_path is not dir"
        return 1
    fi

    return 0
}

bak()
{
    if ! __check_bak_env "$1";then
        return 1
    fi

    bak_name="$1"
    bak_path=$(readlink -e $bak_name)
    bak_name=$(basename $bak_path)
    bak_sfs=$zm_backup_mpath/${bak_name}.sfs

    new_bak_sfs=${bak_sfs}.new
    if [ -e "$new_bak_sfs" ];then
        whiptail --yesno "$bak_sfs is exist, continue?" 30 80
        if [ $? != 0 ];then
            return 0
        fi
        $_SUDO chattr -i $new_bak_sfs
        $_SUDO rm $new_bak_sfs
    fi
    __compress_dir_to_sfs $bak_path $new_bak_sfs
    if [ ! -e $new_bak_sfs ];then
        echo "compress sfs error."
        return 1
    fi

    umbak $bak_name

    $_SUDO mkdir -m 700 -p $zm_backup_old_dir
    if [ -e "$bak_sfs" ];then
        $_SUDO rm -f ${zm_backup_old_dir}/${bak_name}.sfs*
        $_SUDO chattr -i $bak_sfs
        $_SUDO mv ${bak_sfs} ${zm_backup_old_dir}
        for branch in $(seq 1 $zm_bak_max_branch)
        do
            branch_file=${bak_sfs}.${branch}
            if [ -e "$branch_file" ];then
                $_SUDO mv ${branch_file} ${zm_backup_old_dir}/
                continue
            fi
            break
        done  
    fi
    $_SUDO mv $new_bak_sfs $bak_sfs
    $_SUDO chattr +i $bak_sfs

    bak_aufs_dir=$($_SUDO readlink -e $zm_backup_mpath/aufs/$bak_name)
    if [ "$($_SUDO readlink -e $bak_aufs_dir/../..)" = "$zm_backup_mpath" ];then
        $_SUDO rm -rf $bak_aufs_dir
    fi
}

bbak()
{
    if ! __check_bak_env "$1";then
        return 1
    fi

    bak_name="$1"
    bak_path=$(readlink -e $bak_name)
    bak_name=$(basename $bak_path)
    bak_sfs=$zm_backup_mpath/${bak_name}.sfs

    bak_aufs_dir=$($_SUDO readlink -e $zm_backup_mpath/aufs/$bak_name)
    if [ "$($_SUDO readlink -e $bak_aufs_dir/../..)" != "$zm_backup_mpath" ];then
        echo "$bak_aufs_dir is error."
        return
    fi

    for branch in $(seq 1 $zm_bak_max_branch)
    do
        branch_file=${bak_sfs}.${branch}
        if [ ! -e "$branch_file" ];then
            __compress_dir_to_sfs $bak_aufs_dir $branch_file 
            if [ ! -e $branch_file ];then
                echo "compress sfs error."
                return 1
            fi
            break
        fi
    done  

    umbak $bak_name
    $_SUDO rm -rf $bak_aufs_dir
}

mbak()
{
    if [ -z "$@" ];then
        return
    fi

    mount | grep $zm_backup_mpath > /dev/null 2>&1 || return

    bak_name="$1"

    if [ -f ${bak_name} -a ${bak_name##*.} = sfs ];then
        bak_sfs=$PWD/${bak_name}
    else
        bak_sfs=$zm_backup_mpath/${bak_name}.sfs
    fi

    if [ ! -e $bak_sfs ];then
        echo "not found $bak_sfs"
        return 1
    fi

    bak_root_dir=$zm_backup_dir/$bak_name
    bak_aufs_dir=$zm_backup_mpath/aufs/$bak_name
    bak_zm_sfs_dir=$zm_sfs_dir/$bak_name
    if ! readlink -e $bak_root_dir;then
        $_SUDO rmdir $bak_root_dir > /dev/null 2>&1
    fi
    if [ ! -e $bak_root_dir ];then
        $_SUDO mkdir -m 700 -p $bak_root_dir
        $_SUDO mkdir -m 700 -p $bak_aufs_dir
        $_SUDO mkdir -m 700 -p $bak_zm_sfs_dir
        $_SUDO mount $bak_sfs $bak_zm_sfs_dir
        $_SUDO mount -t aufs -o br:$bak_aufs_dir:$bak_zm_sfs_dir=ro none $bak_root_dir

        for branch in $(seq 1 $zm_bak_max_branch)
        do
            branch_file=${bak_sfs}.${branch}
            bak_zm_sfs_branch_dir=$zm_sfs_dir/${bak_name}.${branch}
            if [ -e "$branch_file" ];then
                $_SUDO mkdir -m 700 -p $bak_zm_sfs_branch_dir
                $_SUDO mount $branch_file $bak_zm_sfs_branch_dir
                $_SUDO mount -t aufs -o remount,udba=none,add:1:$bak_zm_sfs_branch_dir=ro+wh none $bak_root_dir
                continue
            fi
            break
        done

        $_SUDO chown $UID $bak_aufs_dir
        $_SUDO chown $UID $bak_root_dir
    fi

    if [ -L $zm_work_dir/$bak_name ];then
        bak_work_dir=$(readlink -e $zm_work_dir/$bak_name)
        if [ "$bak_work_dir" == "$bak_root_dir" ];then
            cd $zm_work_dir/$bak_name 
            return 0
        else
            rm -vf $zm_work_dir/$bak_name
        fi
    fi

    if [ -e $zm_work_dir/$bak_name ];then
        cd $bak_root_dir
        return 0
    fi

    ln -sv $bak_root_dir $zm_work_dir/$bak_name 
    cd $zm_work_dir/$bak_name 
}

umbak()
{
    bak_params=$@
    if [ -z "$@" ];then
        bak_params='.'
    fi

    mount | grep $zm_backup_mpath > /dev/null 2>&1 || return

    if [ ! -e $zm_backup_dir ];then
        return 1
    fi

    for bak_name in $bak_params
    do

        if [ -z $bak_name -o "$bak_name" = '..' ];then
            echo "param error."
            return 0
        fi

        if [ $bak_name = '.' ];then
            bak_name=$(basename $(readlink -e $bak_name))
        fi

        _print_mbak | grep $bak_name > /dev/null || return

        bak_root_dir=$zm_backup_dir/$bak_name
        bak_aufs_dir=$zm_backup_mpath/aufs/$bak_name
        bak_zm_sfs_dir=$zm_sfs_dir/$bak_name

        if [ ! -d $bak_root_dir ];then
            echo "not found $bak_root_dir"
            return 1
        fi
        echo $bak_root_dir | grep $(readlink -e $PWD) > /dev/null && cd
        $_SUDO umount $bak_root_dir

        for branch in $(seq 1 $zm_bak_max_branch)
        do
            branch_sfs_mount_dir=${bak_zm_sfs_dir}.${branch}
            if [ -d "$branch_sfs_mount_dir" ];then
                $_SUDO umount $branch_sfs_mount_dir
                $_SUDO rmdir $branch_sfs_mount_dir
                continue
            fi
            break
        done  

        $_SUDO umount $bak_zm_sfs_dir
        $_SUDO rmdir $bak_root_dir
        $_SUDO rmdir $bak_zm_sfs_dir

        if [ -L $zm_work_dir/$bak_name ];then
            bak_work_dir=$(readlink -e $zm_work_dir/$bak_name)
            if [ "$bak_work_dir" !=  "$bak_root_dir" ];then
                rm -vf $zm_work_dir/$bak_name
            fi
        fi

    done
}

_print_mbak()
{

    dirs=$(cd $zm_backup_dir;/bin/ls */ -d)
    for dir in $dirs 
    do 
        sfs_dir=$(basename $dir)
        if [ "$sfs_dir" != "sfs" ];then
            echo "$sfs_dir"
        fi 
    done 
}

_mbak_complete()
{
    cur=$1
    basename -s .sfs -a $(cd $zm_backup_mpath;/bin/ls *.sfs 2> /dev/null) | grep ".*$cur.*"
}

_umbak_complete()
{
    cur=$1
    _print_mbak | grep ".*$cur.*"
}

function _mbak_complete_bash () 
{
    cur=$2

    COMPREPLY=( $(_mbak_complete $cur) )
    return 0
}

function _umbak_complete_bash () 
{
    cur=$2

    if [ ! -e $zm_backup_dir ];then
        return 1
    fi
    COMPREPLY=( $(_umbak_complete $cur) )
    return 0
}

function _mbak_complete_zsh() 
{
    # tab completion
    # local compl
    # read -l compl
    # reply=("$(_mbak_complete "$compl")")
    # reply=(${(f)"$(_mbak_complete "$compl")"})
    _files -g *(*).sfs
}


# cur_shell=$(ps | grep $$ | awk '{print $4}')
if compctl >/dev/null 2>&1; then
    cur_shell="zsh"
else
    cur_shell="bash"
fi
case $cur_shell in
    bash)
        complete -F _mbak_complete_bash mbak
        complete -F _umbak_complete_bash umbak
        ;;
    zsh)
        compctl -s '$(basename -s .sfs -a $(ls $zm_backup_mpath/*.sfs))' mbak
        compctl -s '$(ls $zm_backup_dir)' umbak
        ;;
esac

