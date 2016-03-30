#!/usr/bin/env python
# -*- coding: utf-8 -*-

import fcntl
import logging
import os
import sys
import json
import getopt
import platform
import time
from datetime import datetime

import math

import mmlog
import subprocess
import atexit, stat

global g_log
global g_images
global g_mounted

g_config = {}


class Enum(set):
    def __getattr__(self, name):
        if name in self:
            return name
        raise AttributeError


env = Enum([
    'arch',
    'user',
    'zones',
    'debug',
    'confirm',
    'user_dir',
    'user_pwd',
    'root_dir',
    'root_pwd',
    'os_name',
    'keep_build',
    'kernel_name',
    'kernel_ver',
    'kernel_params',
    'system_dir',
    'exclude',

    'image_config',

    'build_dir',
    'backup_name',
    'backup_rootdir',
    'backup_workdir',
    'backup_mountdir',
])


def read_config(file_name):
    if not os.path.exists(file_name):
        return
    config_file = open(file_name, 'r')
    data = config_file.readlines()
    for d in data:
        d = d.strip()
        if d == "" or d[0] == '#':
            continue
        kv = d.split('=')
        if len(kv) != 2:
            continue
        k = kv[0].strip()
        v = kv[1].strip()
        set_config(k, v)
    config_file.close()


def init_image_config():
    global g_images
    config_path = get_config(env.image_config)
    if not os.path.exists(config_path):
        g_log.warn(config_path + ' is not exist.')
        g_images = {}
        save_image_config()
        return
    config_file = open(config_path, 'r')
    data = config_file.read()
    g_images = eval(data)
    config_file.close()


def init_mounted_config():
    mounted_path = "/tmp/.zm.mounted"
    if not os.path.exists(mounted_path):
        return
    mounted_file = open(mounted_path, 'r')
    data = mounted_file.read()
    global g_mounted
    g_mounted = eval(data)
    mounted_file.close()


def init_config():
    g_config['optlist'] = []
    g_config['opt'] = {}
    g_config['env'] = {}
    config_name = "zm.cfg"
    default_env()
    read_config(os.path.join(get_config(env.backup_rootdir), config_name))
    read_config(os.path.join(os.getenv("HOME"), '.zm', config_name))
    read_config(config_name)


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


def humanize_filesize(size):
    size = abs(size)
    if (size == 0):
        return "0B"
    units = ['B', 'K', 'M', 'G', 'T', 'P']
    p = math.floor(math.log(size, 2) / 10)
    return "%.2f%s" % (size / math.pow(1024, p), units[int(p)])


def pretty_date(tm=False):
    now = datetime.now()
    diff = now - now
    if type(tm) is int:
        diff = now - datetime.fromtimestamp(tm)
    elif isinstance(time, datetime):
        diff = now - tm
    elif type(tm) is str:
        t = time.strptime(tm, "%Y-%m-%d %H:%M:%S")
        d = datetime(*t[:6])
        diff = now - d

    second_diff = diff.seconds
    day_diff = diff.days

    if day_diff < 0:
        return ''

    if day_diff == 0:
        if second_diff < 10:
            return "just now"
        if second_diff < 60:
            return str(second_diff) + " seconds ago"
        if second_diff < 120:
            return "a minute ago"
        if second_diff < 3600:
            return str(second_diff / 60) + " minutes ago"
        if second_diff < 7200:
            return "an hour ago"
        if second_diff < 86400:
            return str(second_diff / 3600) + " hours ago"
    if day_diff == 1:
        return "Yesterday"
    if day_diff < 7:
        return str(day_diff) + " days ago"
    if day_diff < 31:
        return str(day_diff / 7) + " weeks ago"
    if day_diff < 365:
        return str(day_diff / 30) + " months ago"
    return str(day_diff / 365) + " years ago"


def show_images():
    all_show = {}
    ft = {'name': 0, 'hash': 0, 'base': 1, 'deps': 1, 'path': 0, 'size': 0, 'time': 0}
    for k, v in g_images.items():
        show = {}
        show['name'] = k
        show['hash'] = v['hash']
        base_str = v['base']
        show['base'] = base_str if base_str != '' else '<None>'
        deps_str = ','.join(v['deps'])
        show['deps'] = deps_str if deps_str != '' else '<None>'
        show['path'] = v['path']
        show['size'] = humanize_filesize(v['size'])
        show['time'] = ' ' + pretty_date(v['time']) + ' '
        all_show[k] = show
        for n in ft.keys():
            ft[n] = max(len(show[n]), ft[n])

    show_order = ['name', 'hash', 'base', 'deps', 'time', 'size', 'path']
    format_str = "%%-%ds %%%ds %%%ds %%%ds %%%ds %%%ds %%-%ds" % tuple([ft[s] for s in show_order])
    for k in sorted(all_show.keys()):
        v = all_show[k]
        print(format_str % tuple(v[s] for s in show_order))


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
    config_opt('-k', '--keep-build', env.keep_build, True, 0,
               help="Keep the temporary directory used to make the image")
    config_opt('-a', '--arch', env.arch, None, 1,
               help="system arch, value: i386|amd64",
               values={
                   "i386": "i386",
                   "amd64": "amd64"
               })
    config_opt('', "--os-name", env.os_name, None, 1,
               help="os name, value: debian.stable|debian.testing|debian.unstable|archlinux",
               values={
                   "debian.stable": "stable",
                   "debian.unstable": "testing"
               })
    config_opt('', '--build-dir', env.build_dir, None, 1, help="build temp dir")
    config_opt('', '--kernel-name', env.kernel_name, None, 1, help="kernel name")
    config_opt('', '--kernel-ver', env.kernel_ver, None, 1, help="kernel ver")
    config_opt('', '--kernel-params', env.kernel_params, None, 1, help="kernel params")
    config_opt('', '--system-dir', env.system_dir, None, 1, help="zm system dir")
    config_opt('', '--user', env.user, None, 1, help="zm user name")
    config_opt('', '--user-dir', 'userdir', None, 1, help="zm user config directory")
    config_opt('', '--user-password', env.user_pwd, None, 1, help="user password")
    config_opt('', '--root-password', env.root_pwd, None, 1, help="root password")
    config_opt('-d', '--debug', env.debug, True, 0, help=env.debug)
    config_opt('-y', '--noconfirm', env.confirm, False, 0, help="Bypass any and all 'Are you sure?' messages.")

    config_opt('', '--backup-name', env.backup_name, False, 0, help="config backup name")

    exec_opt('-h', '--help', func=usage, help="show usage")
    exec_opt(lp="--show-env", func=show_all_config, help="show all env config")
    exec_opt(lp="--show-images", func=show_images, help="show all images")
    exec_opt(lp="--add-backup", func=add_backup, argc=1, help="mount backup")
    exec_opt(lp="--create-backup", func=create_backup, argc=1, help="create backup")
    exec_opt(lp="--mount-backup", func=mount_backup, argc=1, help="mount backup")


def has_backup(bakname):
    return bakname in g_images.keys()


def has_mounted(bakname):
    return True


def save_image_config():
    config_path = get_config(env.image_config)
    config_file = open(config_path, 'w')
    data = json.dumps(g_images, indent=4, ensure_ascii=False, sort_keys=True)
    config_file.write(data)
    config_file.close()


def add_image_config(name="", path="", base="", deps=()):
    if not os.path.exists(path):
        g_log.error("%s is not exist." % (path))
        return False
    if has_backup(name):
        g_log.error("backup: %s is exist." % (name))
        return False
    if base != "" and not has_backup(base):
        g_log.error("backup: %s is not exist." % (base))
        return False
    for dep in deps:
        if not has_backup(dep):
            g_log.error("dep backup: %s is not exist." % (dep))
            return False
    import random
    hash_str = "%016x" % random.getrandbits(64)
    if name is '':
        name = hash_str
    image = {}
    image['name'] = name
    image['hash'] = hash_str
    image['base'] = base
    image['deps'] = deps
    image['path'] = path
    image['size'] = os.stat(path).st_size
    image['time'] = datetime.today().strftime("%Y-%m-%d %X")
    g_images[name] = image
    save_image_config()


def remove_backup(backup_name):
    if not has_backup(backup_name):
        g_log.error("remove backup error: %s is not exist." % (backup_name))
        return False
    os.remove(g_images[backup_name]['path'])
    del g_images[backup_name]
    save_image_config()


def mksquashfs(dir, path, exclude=(), comp='lz4', other=()):
    if os.path.exists(path):
        g_log.error("mksquashfs: %s is exist." % (path))
        return False
    other_param = ' '.join([p for p in other] + ['-noappend'])
    exclude_param = ' '.join(["-e '%s'" % (e) for e in exclude])
    cmd = "mksquashfs %s %s -comp %s %s -regex %s" % (dir, path, comp, other_param, exclude_param)
    return run_cmd_root(cmd)


def create_backup(bakdir):
    bakdir = bakdir.rstrip('/')
    if not os.path.exists(bakdir):
        g_log.error(bakdir + " not exist.")
        sys.exit(1)
    backup_name = get_config(env.backup_name, os.path.basename(bakdir))
    if has_backup(backup_name):
        remove_backup(backup_name)
    # backup_file = os.path.join(get_config(env.backup_rootdir), backup_name + '.sfs')
    backup_file = os.path.join("/tmp", backup_name + '.sfs')
    exclude = get_config(env.exclude, ())
    if mksquashfs(bakdir, backup_file, exclude):
        add_image_config(backup_name, backup_file)


def add_backup(bakfile):
    pass


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
    bakrootdir = os.path.join(get_config(env.backup_workdir), bakname)


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
    set_config(env.zones, "")
    set_config(env.keep_build, False)
    set_config(env.arch, platform.machine().lower())
    set_config(env.os_name, "archlinux")
    set_config(env.build_dir, "/tmp/zm_build")
    set_config(env.kernel_name, "vmlinuz")
    set_config(env.kernel_ver, "")
    set_config(env.kernel_params, "")
    user = os.getenv("USER")
    sudo_user = os.getenv("SUDO_USER")
    set_config(env.user, user if sudo_user is None else sudo_user)
    set_config(env.debug, False)
    set_config(env.confirm, True)

    set_config(env.backup_rootdir, "/media/backup")
    set_config(env.backup_mountdir, "/media/bak")

    # set_config(env.image_config, "/media/backup/image.json")
    set_config(env.image_config, "image.json")


def which(file):
    for path in os.environ["PATH"].split(os.pathsep):
        if os.path.exists(os.path.join(path, file)):
            return True
    return False


def run_cmd(cmd):
    g_log.info(cmd)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    print(''.join(line.decode() for line in p.stdout.readlines()))
    p.wait(3)
    if p.returncode != 0:
        g_log.info('return %d' % (p.returncode))
        g_log.error(''.join(line.decode() for line in p.stderr.readlines()))
        return False
    return True


def run_cmd_root(cmd):
    ret = False
    if os.geteuid():
        if which('sudo'):
            ret = run_cmd('sudo ' + cmd)
        elif which('su'):
            ret = run_cmd('su -c ' + cmd)
        else:
            print("can't find sudo or su, you must use root.")
    else:
        ret = run_cmd(cmd)
    return ret


def proc_default_env():
    zones = get_config(env.zones)
    if zones != "":
        mmlog.setZones(zones.split(","))

    sfs_part_mpath = ""
    user = get_config(env.user)
    path = '%s.%s.%s' % (user, get_config(env.os_name), get_config(env.arch))
    if get_config(env.system_dir) == "":
        set_config(env.system_dir, os.path.join(sfs_part_mpath, 'linux', path))
    userdir = get_config(env.user_dir)
    if userdir == "":
        userdir = os.path.expanduser('~' + user)
    if os.path.exists(userdir):
        set_config(env.user_dir, userdir)
    user_pwd = get_config(env.user_pwd)
    if user_pwd == "":
        user_pwd = user
        set_config(env.user_pwd, user)
    root_pwd = get_config(env.root_pwd)
    if root_pwd == "":
        set_config(env.root_pwd, user_pwd)


def init_options():
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
    global g_log
    g_log = mmlog.getLogger("zm.log")
    g_log.setLevel(logging.NOTSET)
    init_config()
    init_options()
    init_image_config()
    proc_options()
    # run_cmd("cat /proc/mounts | awk '{print $2}'")
