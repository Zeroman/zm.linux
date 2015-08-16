# zm(8) completion                                       -*- shell-script -*-

zm_os_id=$(zm --print-os-id)
zm_backup_workdir=$(zm --print-backup-workdir)
zm_backup_mountdir=$(zm --print-backup-mountdir)

_zm()
{
    local cur prev words cword
    _init_completion -n = || return

    #  only takes options, tabbing after command name adds a single dash
    [[ $cword -eq 1 && -z "$cur" ]] &&
    {
        compopt -o nospace
        COMPREPLY=( "-" )
        return 0
    }

    case $cur in
        -*)
            _longopt zm
            return 0
            ;;
    esac


    case $prev in
        --mount-backup|--remove-backup)
            local opts=$(basename -s .sfs -a $(cd $zm_backup_mountdir;/bin/ls *.sfs 2> /dev/null))
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
        --umount-backup)
            local opts=$(basename -a $(cd $zm_backup_workdir;/bin/ls */ -d 2> /dev/null))
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
        --zm-user)
            local zm_workdir=$(zm --print-workdir)
            local opts=$(echo $USER $(basename -a $(cd $zm_workdir/user;/bin/ls */ -d 2> /dev/null)) | sort | uniq)
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
        --install-zm|--build-dir|--zm-userdir|--zm-dir)
          _filedir -d
          return 0
          ;;
        --arch)
            local opts="amd64 i386"
            [[ "$zm_os_id" == "archlinux" ]] && opts="x86_64 i386"
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
    esac
} &&
complete -F _zm zm 

mb()
{
    new_dir=$(zm --mount-backup $@)
    test -z "$new_dir" || cd $new_dir
}

umb()
{
    zm --umount-backup $@
}

_mb()
{
    local cur prev words cword
    _init_completion -n = || return

    local opts=$(basename -s .sfs -a $(cd $zm_backup_mountdir;/bin/ls *.sfs 2> /dev/null))
    COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
    return 0
} &&
complete -F _mb mb

_umb()
{
    local cur prev words cword
    _init_completion -n = || return

    local opts=$(basename -a $(cd $zm_backup_workdir;/bin/ls */ -d 2> /dev/null))
    COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
    return 0
} &&
complete -F _umb umb

# ex: ts=4 sw=4 et filetype=sh
