# zm(8) completion                                       -*- shell-script -*-

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

    os_id=$(lsb_release -i -s)
    zm_backup_dir=/media/bak
    zm_backup_mpath=/media/backup

    case $prev in
        --mount-backup|--remove-backup)
            local opts=$(basename -s .sfs -a $(cd $zm_backup_mpath;/bin/ls *.sfs 2> /dev/null))
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
        --umount-backup)
            local opts=$(basename -s .sfs -a $(cd $zm_backup_dir;/bin/ls */ -d 2> /dev/null))
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
        --install-zm|--build-dir|--zm-userdir|--zm-dir)
          _filedir -d
          return 0
          ;;
        --arch)
            local opts="amd64 i386"
            [[ "$os_id" == "archlinux" ]] && opts="x86_64 i386"
            COMPREPLY=( $( compgen -W '$opts' -- "$cur" ) )
            return 0
            ;;
    esac
} &&
complete -F _zm zm 
# complete -F _longopt zm 

# ex: ts=4 sw=4 et filetype=sh
