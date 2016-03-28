#!/usr/bin/env python
# -*- coding: utf-8 -*-

import fcntl
import logging
import os
import sys
import getopt
import platform
import time
import mmlog
import subprocess

global g_log
g_config = {}
g_log = None


def read_backup_config():
    bakrootdir = get_config("backup_rootdir")
    config_file = open(os.path.join(bakrootdir), "config.json")
    data = config_file.read()
    config_file.close()


def set_config(node, value):
    g_config['env'][node] = value


def get_config(node, defvalue=""):
    env_config = g_config['env']
    if node not in env_config.keys():
        env_config[node] = defvalue
    return env_config[node]


def show_map(map, prefix=""):
    if map is None or len(map) == 0:
        return
    max_len = max(len(i) for i in map.keys())
    format = '%%s%%-%ds : %%s' % (max_len)
    for key in sorted(map.keys()):
        print(format % (prefix, key, map[key]))


def show_all_config():
    env_config = g_config['env']
    show_map(env_config)


def add_option(sp='', lp='', argc=0, func=None, t='config', help='', values=None):
    if sp == '' and lp == '':
        return False
    opt = {}
    opt['sp'] = sp
    opt['lp'] = lp
    opt['argc'] = argc
    opt['func'] = func
    opt['help'] = help
    opt['type'] = t
    opt['values'] = values
    if sp != "":
        g_config['opt'][sp] = opt
    if lp != "":
        g_config['opt'][lp] = opt
    g_config['optlist'].append(opt)


def config_opt(sp='', lp='', key='', value=None, argc=0, help='', values=None):
    func = None
    if argc > 0 and value is None:
        func = lambda arg1: set_config(key, arg1)
    else:
        func = lambda: set_config(key, value)
    add_option(sp, lp, argc, func=func, t='config', help=help, values=values)


def exec_opt(sp='', lp='', func=None, argc=0, help='', values=None):
    add_option(sp, lp, argc, func=func, t='exec', help=help, values=values)


def add_all_options():
    config_opt('-z', '--zone', 'zones', None, 1, help="log zones")
    config_opt('-k', '--keep-build', 'keepbuild', True, 0,
               help="Keep the temporary directory used to make the image")
    config_opt('-a', '--arch', 'arch', None, 1,
               help="system arch, value: i386|amd64",
               values={
                   "i386": "i386",
                   "amd64": "amd64"
               })
    config_opt('', "--os-name", 'osname', None, 1,
               help="os name, value: debian.stable|debian.testing|debian.unstable|archlinux",
               values={
                   "debian.stable": "stable",
                   "debian.unstable": "testing"
               })
    config_opt('', '--build-dir', 'builddir', None, 1, help="build temp dir")
    config_opt('', '--kernel-name', 'kernelname', None, 1, help="kernel name")
    config_opt('', '--kernel-ver', 'kernelver', None, 1, help="kernel ver")
    config_opt('', '--kernel-params', 'kernelparams', None, 1, help="kernel params")
    config_opt('', '--system-dir', 'systemdir', None, 1, help="zm system dir")
    config_opt('', '--user', 'user', None, 1, help="zm user name")
    config_opt('', '--user-dir', 'userdir', None, 1, help="zm user config directory")
    config_opt('', '--user-password', 'userpwd', None, 1, help="user password")
    config_opt('', '--root-password', 'rootpwd', None, 1, help="root password")
    config_opt('-d', '--debug', 'debug', True, 0, help="debug")
    config_opt('-y', '--noconfirm', 'confirm', False, 0, help="Bypass any and all 'Are you sure?' messages.")

    exec_opt('-h', '--help', func=usage, help="show usage")
    exec_opt(lp="--show-env", func=show_all_config, help="show all env config")
    exec_opt(lp="--mount-backup", func=mount_backup, argc=1, help="mount backup")


def has_backup(bakname):
    return True


def has_mounted(bakname):
    return True


def add_backup(name="", hash="", dir="", base="", deps=[], path="", size=0, time=""):
    if has_backup(name):
        g_log.error("backup: %s is exist." % (name))
        return False
    if not has_backup(base):
        g_log.error("backup: %s is not exist." % (base))
        return False
    for dep in deps:
        if not has_backup(dep):
            g_log.error("dep backup: %s is not exist." % (dep))
            return False
    images = {}
    images['name'] = name
    images['hash'] = hash
    images['dir'] = dir
    images['base'] = base
    images['deps'] = deps
    images['path'] = path
    images['size'] = size
    images['time'] = time


def mount_backup(bakname):
    if bakname is "":
        g_log.error("backup: backup name is null.")
        return False
    if not has_backup(bakname):
        g_log.error("backup: %s is not exist." % (bakname))
        return False
    if has_mounted(bakname):
        g_log.warning("backup: %s is mounted." % (bakname))
        return True
    bakrootdir = os.path.join(get_config("backup_workdir"), bakname)


def run_option(o, p, t="config"):
    opt = g_config['opt'][o]
    if opt['type'] != t:
        return
    if p is '?':
        print(o + ' help:')
        show_map(opt['values'], "  ")
        sys.exit(0)
    func = opt['func']
    if opt['argc'] > 0:
        func(p)
    else:
        func()


def default_env():
    set_config("zones", "")
    set_config("keepbuild", False)
    set_config("arch", platform.machine().lower())
    set_config("osname", "archlinux")
    set_config("builddir", "/tmp/zm_build")
    set_config("kernelname", "vmlinuz")
    set_config("kernelver", "")
    set_config("kernelparams", "")
    user = os.getenv("USER")
    sudo_user = os.getenv("SUDO_USER")
    set_config("user", user if sudo_user is None else sudo_user)
    set_config("debug", False)
    set_config("confirm", True)

    set_config("backup_rootdir", "/media/backup")
    set_config("backup_mountdir", "/media/bak")


def which(file):
    for path in os.environ["PATH"].split(os.pathsep):
        if os.path.exists(os.path.join(path, file)):
            return True
    return False


def run_cmd(cmd):
    print(cmd)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    print(''.join(line.decode() for line in p.stdout.readlines()))
    p.wait(3)
    print(p.returncode)
    if p.returncode != 0:
        print(p.stderr.readlines())


def run_cmd_root(cmd):
    if os.geteuid():
        if which('sudo'):
            run_cmd('sudo ' + cmd)
        elif which('su'):
            run_cmd('su -c ' + cmd)
        else:
            print("can't find sudo or su, you must use root.")
            sys.exit(1)
    else:
        run_cmd(cmd)


def proc_default_env():
    zones = get_config("zones")
    if zones != "":
        mmlog.setZones(zones.split(","))

    sfs_part_mpath = ""
    user = get_config("user")
    path = '%s.%s.%s' % (user, get_config("osname"), get_config("arch"))
    if get_config("systemdir") == "":
        set_config("systemdir", os.path.join(sfs_part_mpath, 'linux', path))
    userdir = get_config("userdir")
    if userdir == "":
        userdir = os.path.expanduser('~' + user)
    if os.path.exists(userdir):
        set_config("userdir", userdir)
    userpwd = get_config("userpwd")
    if userpwd == "":
        userpwd = user
        set_config("userpwd", user)
    rootpwd = get_config("rootpwd")
    if rootpwd == "":
        set_config("rootpwd", userpwd)


def init_options():
    global g_log
    g_log = mmlog.getLogger("zm.log")
    g_log.setLevel(logging.NOTSET)

    g_config['optlist'] = []
    g_config['opt'] = {}
    g_config['env'] = {}

    default_env()
    add_all_options()

    if len(sys.argv) == 1:
        usage()


def proc_options():
    short_str = ""
    long_list = []
    for (k, v) in g_config['opt'].items():
        argc = v['argc']
        if k.startswith('--'):
            long_list.append(k[2:] + "=" if argc > 0 else k[2:])
        else:
            short_str += k[1:] + ":" if argc > 0 else k[1:]
    # print("short = ", short_str)
    # print("long = ", long_list)

    try:
        opts, args = getopt.getopt(sys.argv[1:], short_str, long_list)
        # print(opts)
    except getopt.GetoptError as err:
        # print help information and exit:
        print(err)  # will print something like "option -a not recognized"
        # usage()
        sys.exit(2)

    for o, a in opts:
        run_option(o, a, 'config')
    proc_default_env()
    for o, a in opts:
        run_option(o, a, 'exec')


def usage():
    print("Usage: zm [OPTION]... [ARGS]... ")
    print("")
    print("Mandatory arguments to long options are mandatory for short options too.")
    map_help = {}
    for opt in g_config['optlist']:
        key = ""
        sp = opt['sp']
        lp = opt['lp']
        if sp is not "" and lp is not "":
            key = '%s, %s' % (sp, lp)
        elif sp is not "":
            key = sp
        elif lp is not "":
            key = lp
        if key is not "":
            map_help[key] = opt['help']
    show_map(map_help, "  ")
    print("")
    print("Exit status:")
    print(" 0  if OK,")
    print(" 1  if minor problems (e.g., cannot access subdirectory),")
    print(" 2  if serious trouble (e.g., cannot access command-line argument).")


def lock_process():
    import atexit, stat
    lock_file = "/tmp/.zm.lock"
    if os.path.exists(lock_file):
        print(lock_file + " is exist, exit now.")
        return True
    open(lock_file, 'w').close()
    os.chmod(lock_file, stat.S_IRWXU | stat.S_IRGRP | stat.S_IROTH)
    atexit.register(lambda: os.remove(lock_file))
    return False


if __name__ == '__main__':
    if lock_process():
        sys.exit(1)
    init_options()
    proc_options()
    # run_cmd("cat /proc/mounts | awk '{print $2}'")
