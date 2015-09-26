#!/bin/bash - 
#===============================================================================
#          FILE: zm_test.sh
#         USAGE: ./zm_test.sh 
#   DESCRIPTION: 
#
#        AUTHOR: Zeroman Yang, 51feel@gmail.com
#       CREATED: 08/20/2015 14:00
#      REVISION: 0.01 
#===============================================================================

# TEST_DIR=$(mktemp -d)
TEST_DIR=/tmp/zm_test
mkdir -p $TEST_DIR

ZM=zm
if [ -x /work/zm/zm ];then
    ZM=/work/zm/zm
fi


sfs_mpath=/media/sfs
unionfs_mpath=/media/unionfs
work_mountdir=/work
backup_mountdir=$($ZM --print-backup-mountdir)
backup_workdir=$($ZM --print-backup-workdir)
log_file=$TEST_DIR/test.log
unionfs_clean_file=.unionfs.fs.clean
max_branch=$($ZM --print-max-branch)
echo $max_bran

> $log_file

err()
{
    echo Error: "$@"
    $ZM --umount-backup zmtest
    exit 1
}

check_err()
{
    echo Error: "$@" | tee -a $log_file
}

check_pass()
{
    echo Pass: "$@" | tee -a $log_file
}

get_backup_unionfs_dir()
{
    local bak_name="$1"

    if modprobe overlay > /dev/null 2>&1;then
        echo "$backup_mountdir/unionfs/${bak_name}/upper"
    elif modprobe aufs > /dev/null 2>&1;then
        echo "$backup_mountdir/unionfs/${bak_name}/aufs"
    else
        err "no support union filesystem."
    fi
}

mount_test_backup()
{
    if ! $ZM --mount-backup zmtest > /dev/null;then
        err "mount zmtest error"
    fi
}

umount_test_backup()
{
    if ! $ZM --umount-backup zmtest > /dev/null;then
        err "umount zmtest error"
    fi
}

check_test_backup()
{
    num=$1
    shift

    local backup_dir=$work_mountdir/zmtest

    for n in $(seq 1 $num); do
        test -e $backup_dir/$n || err "$backup_dir/$n not exist, [$(ls $backup_dir])"
        local str=$(cat $backup_dir/$n)
        if [ "$str" != "$n" ];then
            check_err "[$@] check file $n != ($str)"
        else
            check_pass "[$@] check file $n"
        fi
    done

    if [ -d $sfs_mpath/zmtest.${num} ];then
        ret=$(ls -1 $sfs_mpath/zmtest.${num}/ | sort -n)
        expect_ret=$num
        if [ "$ret" != "$expect_ret" ];then
            check_err "[$@] check sfs dir list error $num $ret $(mount)"
        else
            check_pass "[$@] check sfs dir list ok $num"
        fi
    fi

    ret=$(ls -1 $work_mountdir/zmtest | sort -n)
    expect_ret=$(seq 1 $num)
    if [ "$ret" != "$expect_ret" ];then
        check_err "[$@] check work dir list error $num [$(echo $ret)]"
    else
        check_pass "[$@] check work dir list ok $num"
    fi

}

test_backup_dir()
{
    local backup_dir=$TEST_DIR/zmtest

    rm -rf $backup_dir
    mkdir -p $backup_dir

    for i in $(seq 1 5); do
        echo $i > $backup_dir/$i
        $ZM --backup-dir $backup_dir > /dev/null

        mount_test_backup 
        check_test_backup $i "$FUNCNAME"
        umount_test_backup
    done
    $ZM --remove-backup zmtest
}

test_backup_branch()
{
    local backup_dir=$TEST_DIR/zmtest

    $ZM --remove-backup zmtest
    rm -rf $backup_dir
    mkdir -p $backup_dir
    echo 1111 > $backup_dir/1
    $ZM --backup-dir $backup_dir > /dev/null

    for i in $(seq 1 $max_branch); do
        mount_test_backup
        echo $i > $work_mountdir/zmtest/$i
        $ZM --backup-branch zmtest > /dev/null
        local clean_file=$(get_backup_unionfs_dir zmtest)/$unionfs_clean_file
        if [ ! -e $clean_file ];then
            check_err "$clean_file is not exist."
        fi
        umount_test_backup

        mount_test_backup
        if [ ! -d $sfs_mpath/zmtest.${i} ];then
            check_err "$sfs_mpath/zmtest.${i} is not exist."
        fi
        check_test_backup $i "$FUNCNAME"
        umount_test_backup
    done

    for i in $(seq 1 10); do
        if $ZM --backup-branch zmtest;then
            check_err "max branch error."
        fi
    done

    mount_test_backup
    echo t > $work_mountdir/zmtest/t
    umount_test_backup

    $ZM --remove-backup-branch zmtest 0
    if [ -d $(get_backup_unionfs_dir zmtest) ];then
        check_err "remove backup branch error."
    fi

    local cur_branch=$max_branch
    $ZM --remove-backup-branch zmtest 1
    if [ -e $backup_mountdir/zmtest.sfs.$cur_branch ];then
        check_err "remove backup branch last one"
    fi
    $ZM --backup-info zmtest
    if [ ! -e $backup_mountdir/zmtest.sfs.$(expr $cur_branch - 1) ];then
        check_err "remove more backup branch"
    fi

    $ZM --remove-backup zmtest
}

test_mount_backup()
{
    echo $TEST_DIR
    $ZM --mount-backup 

}

test_umount_bakcup()
{
    echo $TEST_DIR

}

test_exe_path()
{
    local backup_dir=$TEST_DIR/zmtest
    local work_dir=$work_mountdir/zmtest

    rm -rf $backup_dir
    mkdir -p $backup_dir

    echo '
#include <stdio.h>
#include <unistd.h>

int main(int argc, char const* argv[])
{
    char buf[4096];
    readlink("/proc/self/exe", buf, sizeof(buf));
    printf("%s\n", buf);
    return 0;
}
    ' > $backup_dir/test_exe_path.c
    gcc $backup_dir/test_exe_path.c -o $backup_dir/test_exe_path.elf

    $ZM --backup-dir $backup_dir > /dev/null


    mount_test_backup 
    $work_dir/test_exe_path.elf
    umount_test_backup
    $ZM --remove-backup zmtest
}

test_all()
{
    test_backup_dir
    test_backup_branch
    test_mount_backup
    test_umount_bakcup
}

show_err()
{
    echo ""
    echo "-------------------------------------"
    cat $TEST_DIR/test.log | grep Error
    echo "-------------------------------------"
}

rm -rf $TEST_DIR
mkdir -p $TEST_DIR
while [ $# -gt 0 ]; do
    case $1 in
        --zm)
            ZM=$2
            ;;
        *)
            test_$1
            show_err
            ;;
    esac
    shift
done
# rm -rf $TEST_DIR
