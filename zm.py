#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import fcntl
import hashlib
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
global g_image_names
global g_images_dir

g_config = {}


class Enum(set):
    def __getattr__(self, name):
        if name in self:
            return name
        raise AttributeError


class Const(object):
    class ConstError(TypeError):
        pass

    def __setattr__(self, name, value):
        if name in self.__dict__.keys():
            raise (self.ConstError, "Cant rebind const(%s)" % name)
        self.__dict__[name] = value

    def __delattr__(self, name):
        if name in self.__dict__.keys():
            raise (self.ConstError, "Cant unbind const(%s)" % name)
        raise (NameError, name)


c = Const()
c.image_type = 'type'
c.mount_mode = 'mount_mode'
c.mounted = 'mounted'
c.extract = 'extract'
c.cmd = 'command'
c.used = 'used'
c.name = 'name'
c.time_format = "%Y-%m-%d %X %f"
c.sfs = 'sfs'
c.iso = 'iso'
c.dir = 'dir'
c.parent = 'parent'
c.children = 'children'
c.hash = 'hash'
c.deps = 'deps'
c.size = 'size'
c.path = 'path'
c.by = 'by'
c.opath = 'outpath'
c.status = 'status'
c.time = 'time'

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
    'mounted_config',
    'extract_config',

    'build_dir',
    'backup_name',
    'backup_rootdir',
    'backup_workdir',
    'backup_tempdir',
    'backup_unionfsdir',

    'backup_deps',
    'backup_parent',

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


def read_json_config(config_path):
    config_file = open(config_path, 'r')
    data = config_file.read()
    config_file.close()
    return json.loads(data)


def save_json_config(config_path, config):
    config_file = open(config_path, 'w')
    data = json.dumps(config, indent=4, ensure_ascii=False, sort_keys=True)
    config_file.write(data)
    config_file.close()


def init_image_config():
    global g_images
    global g_image_names
    g_image_names = {}
    config_path = get_config(env.image_config)
    if not os.path.exists(config_path):
        g_log.warn(config_path + ' is not exist.')
        g_images = {}
        save_json_config(get_config(env.image_config), g_images)
        return
    g_images = read_json_config(config_path)
    for k, v in g_images.items():
        name = v[c.name]
        if name != '':
            g_image_names[name] = v


def init_mounted_config():
    global g_images_dir
    g_images_dir = {}
    mounted_images = {}
    extract_images = {}
    mounted_path = get_config(env.mounted_config)
    extract_path = get_config(env.extract_config)
    if os.path.exists(mounted_path):
        mounted_images = read_json_config(mounted_path)
    if os.path.exists(extract_path):
        extract_images = read_json_config(extract_path)
    for k, v in mounted_images.items():
        v[c.status] = c.mounted
        g_images_dir[k] = v
    for k, v in extract_images.items():
        v[c.status] = c.extract
        g_images_dir[k] = v


def save_mounted_config(mounted=False, extract=False):
    mounted_images = {}
    extract_images = {}
    for k, v in g_images_dir.items():
        if mounted and v[c.status] == c.mounted:
            mounted_images[k] = v
        elif extract and v[c.status] == c.extract:
            extract_images[k] = v
    if mounted:
        mounted_path = get_config(env.mounted_config)
        save_json_config(mounted_path, mounted_images)
    if extract:
        extract_path = get_config(env.extract_config)
        save_json_config(extract_path, extract_images)


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


def show_map_1level(map, prefix=""):
    if map is None or len(map) == 0:
        return
    max_len = max(len(i) for i in map.keys())
    format = '%%s%%-%ds : %%s' % (max_len)
    for key in sorted(map.keys()):
        print(format % (prefix, key, map[key]))


def show_all_config():
    env_config = g_config['env']
    show_map_1level(env_config)


def humanize_filesize(size):
    size = abs(size)
    if (size == 0):
        return "0B"
    units = ['B', 'K', 'M', 'G', 'T', 'P']
    p = math.floor(math.log(size, 2) / 10)
    return "%.2f%s" % (size / math.pow(1024, p), units[int(p)])


def get_dirsize(start_path=None):
    total_size = 0
    if start_path == None:
        return total_size
    for dirpath, dirnames, filenames in os.walk(start_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            total_size += os.path.getsize(fp)
    return total_size


def pretty_name(name):
    image = get_backup(name)
    name = image[c.name]
    if name == "":
        name = image['oldname']
    return "%s(%s:%s)" % (image[c.hash], name, image[c.image_type])


def pretty_date(tm=None):
    now = datetime.now()
    diff = now - now
    if type(tm) is int:
        diff = now - datetime.fromtimestamp(tm)
    elif isinstance(time, datetime):
        diff = now - tm
    elif type(tm) is str:
        t = time.strptime(tm, c.time_format)
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
            return "%d seconds ago" % (second_diff)
        if second_diff < 120:
            return "a minute ago"
        if second_diff < 3600:
            return "%d minutes ago" % (second_diff / 60)
        if second_diff < 7200:
            return "an hour ago"
        if second_diff < 86400:
            return "%d hours ago" % (second_diff / 3600)
    if day_diff == 1:
        return "Yesterday"
    if day_diff < 7:
        return "%d days ago" % (day_diff)
    if day_diff < 31:
        return "%d weeks ago" % (day_diff / 7)
    if day_diff < 365:
        return "%d months ago" % (day_diff / 30)
    return "%d years ago" % (day_diff / 365)


def show_map(base, map_data):
    data = map_data.items()
    while data:
        k, v = data.pop(0)
        sys.stdout.write('%s->%s' % (base, k))
        items = v.items()
        if len(items) == 1:
            (ik, iv) = items[0]
            if not iv.items():
                # sys.stdout.write('->%s' % ik)
                sys.stdout.write('\n')
                continue
        sys.stdout.write('\n')
        if data:
            show_map(base + '|   ', v)
        else:
            show_map(base + '    ', v)


def show_image(name, level=0):
    image = get_backup(name)
    if image is None:
        g_log.error("no backup %s" % name)
        return
    name = image[c.name]
    type = image[c.image_type]
    if name == "":
        name = image['oldname']
    info = "%s (%s %s) %s" % (image[c.hash], name, type, image['path'])
    print('' + '  ' * level + '└─' + info)
    parent = image[c.parent]
    if parent is not None:
        show_image(parent, level=(level + 1))


def show_images_old():
    all_show = {}
    ft = {c.name: 0, c.hash: 0, c.deps: 1, 'path': 0, 'size': 0, c.time: 0}
    for k, v in g_image_names.items():
        show = {}
        show[c.name] = k
        show[c.hash] = v[c.hash]
        deps_str = ','.join(v[c.deps])
        show[c.deps] = deps_str if deps_str != '' else '<None>'
        show['path'] = v['path']
        if v[c.image_type] == c.dir:
            size = get_dirsize(v['path'])
        else:
            size = v['size']
        show['size'] = humanize_filesize(size)
        show[c.time] = ' ' + pretty_date(v[c.time]) + ' '
        all_show[k] = show
        for n in ft.keys():
            ft[n] = max(len(show[n]), ft[n])

    show_order = [c.name, c.hash, c.deps, c.time, 'size', 'path']
    format_str = "%%-%ds %%%ds %%%ds %%%ds %%%ds %%-%ds" % tuple([ft[s] for s in show_order])
    for k in sorted(all_show.keys()):
        v = all_show[k]
        print(format_str % tuple(v[s] for s in show_order))

def show_old_images():
    show_images('old')

def show_images(view='live'):
    all_show = {}
    ft = {
        c.name: [0, '%%-%ds'],
        c.hash: [0, '%%-%ds'],
        c.deps: [1, '%%%ds'],
        c.time: [0, '%%%ds'],
        c.size: [0, '%%%ds'],
        c.path: [0, '%%-%ds'],
        'tm': [0, '%%%ds'],
    }
    for k, v in g_images.items():
        if view == 'live' and v[c.name] == '' and len(v[c.children]) == 0:
            continue
        if view == 'old' and v[c.name] != '':
            continue
        show = {
            c.hash: v[c.hash],
            c.time: ' ' + pretty_date(v[c.time]) + ' ',
            c.path: v[c.path],
            'tm': v[c.time],
        }

        name = v["oldname"] if v[c.name] == '' else v[c.name]
        show[c.name] = "(%s:%s)" % (name, v[c.image_type])

        deps_str = ','.join(v[c.deps])
        show[c.deps] = deps_str if deps_str != '' else '<None>'
        if v[c.image_type] == c.dir:
            size = get_dirsize(v['path'])
        else:
            size = v['size']
        show['size'] = humanize_filesize(size)

        all_show[k] = show
        for n in ft.keys():
            ft[n][0] = max(len(show[n]), ft[n][0])

    show_order = [c.name, c.hash, c.deps, c.time, c.size, c.path]
    format_str = ' '.join([ft[s][1] for s in show_order]) % tuple([ft[s][0] for s in show_order])

    for (k, v) in sorted(all_show.items(), key=lambda d: d[1]['tm'], reverse=True):
        print(format_str % tuple(v[s] for s in show_order))




def show_mount(name, level=0):
    image = get_backup(name)
    if image is None:
        g_log.error("no backup %s" % name)
        return
    hash = image[c.hash]
    if hash not in g_images_dir.keys():
        g_log.error("%s not mount" % name)
        return False
    name = image[c.name]
    type = image[c.image_type]
    if name == "":
        name = image['oldname']
    m_image = g_images_dir[hash]
    info = "%s (%s %s) %s" % (image[c.hash], name, type, image['path'])
    print('' + '  ' * level + '└─' + info)
    level = level + 1
    for hash in m_image[c.used]:
        show_mount(hash, level=level)


def show_mounts():
    all_show = {}
    ft = {
        c.name: [0, '%%-%ds'],
        c.opath: [0, '%%-%ds'],
        c.time: [1, '%%%ds'],
        c.by: [0, '%%%ds'],
        c.used: [0, '%%%ds'],
        'tm': [0, '%%%ds'],
    }
    for k, v in g_images_dir.items():
        show = {
            c.name: pretty_name(v[c.hash]),
            c.opath: v[c.opath],
            c.time: ' ' + pretty_date(v[c.time]) + ' ',
            'tm': v[c.time],
            c.by: str(len(v[c.by])),
            c.used: str(len(v[c.used]))
        }
        all_show[k] = show
        for n in ft.keys():
            ft[n][0] = max(len(show[n]), ft[n][0])

    show_order = [c.name, c.opath, c.by, c.used, c.time]
    format_str = ' '.join([ft[s][1] for s in show_order]) % tuple([ft[s][0] for s in show_order])

    for (k, v) in sorted(all_show.items(), key=lambda d: d[1]['tm'], reverse=True):
        print(format_str % tuple(v[s] for s in show_order))


def add_option(sp='', lp='', argc=0, func=None, t='config', help='', values=None):
    if sp == '' and lp == '':
        return False
    opt = {
        'sp': sp,
        'lp': lp,
        'argc': argc,
        'func': func,
        'help': help,
        c.image_type: t,
        'values': values
    }
    if sp != "":
        g_config['opt'][sp] = opt
    if lp != "":
        g_config['opt'][lp] = opt
    g_config['optlist'].append(opt)


def config_opt(sp='', lp='', key='', value=None, argc=0, help='', values=None):
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
    config_opt('', '--backup-deps', env.backup_deps, None, 1, help="create backup deps params")
    config_opt('', '--backup-parent', env.backup_parent, None, 1, help="create backup parent")

    config_opt('', '--backup-name', env.backup_name, None, 1, help="config backup name")

    exec_opt('-h', '--help', func=usage, help="show usage")
    exec_opt(lp="--show-env", func=show_all_config, help="show all env config")
    exec_opt(lp="--show-images", func=show_images, help="show all images")
    exec_opt(lp="--show-oldimages", func=show_old_images, help="show old images")
    exec_opt(lp="--show-mounts", func=show_mounts, help="show all mounted images")
    exec_opt(lp="--show-mount", func=show_mount, argc=1, help="show mounted image by name")
    exec_opt(lp="--show-image", func=show_image, argc=1, help="show image by param")
    exec_opt(lp="--add-backup", func=add_backup, argc=1, help="mount backup")
    exec_opt(lp="--create-backup", func=create_backup_cmd, argc=1, help="create backup")
    exec_opt(lp="--remove-backup", func=remove_backup, argc=1, help="remove backup")
    exec_opt(lp="--compact-backup", func=compact_backup, argc=1, help="compact backup of sfs type")
    exec_opt(lp="--mount-backup", func=mount_backup, argc=1, help="mount backup")
    exec_opt(lp="--umount-backup", func=umount_backup, argc=1, help="umount backup")
    exec_opt(lp="--check-backup", func=check_backup, argc=1, help="check backup")
    exec_opt(lp="--backup-info", func=backup_info, argc=1, help="check backup")


def has_backup(name):
    return True if get_backup(name) != None else False


def get_backup(name):
    image = None
    if name in g_image_names.keys():
        image = g_image_names[name]
    if image == None and name in g_images.keys():
        image = g_images[name]
    return image


def check_backup(name):
    image = get_backup(name)
    if image == None:
        g_log.error("%s is not exist." % (name))
        return False
    ret = True
    image_path = image['path']
    if not os.path.exists(image_path):
        g_log.error("%s : file %s is not exist." % (name, image_path))
        ret = False
    for dep in image[c.deps]:
        ret &= check_backup(dep)
    return ret


def backup_info(name):
    print(get_parent_list(name))


def has_mounted(hash, mode=None):
    if hash not in g_images_dir.keys():
        return False
    if mode is None:
        return True
    return mode == g_images_dir[hash][c.mount_mode]


def add_image_config(name="", path="", type="", parent=None, deps=()):
    if has_backup(name):
        g_log.error("backup: %s is exist." % (name))
        return False
    if not os.path.exists(path) and parent == None:
        g_log.error("%s is not exist." % (path))
        return False
    if parent != None and not has_backup(parent):
        g_log.error("backup: parent %s is not exist." % (parent))
        return False
    for dep in deps:
        if not has_backup(dep):
            g_log.error("dep backup: %s is not exist." % (dep))
            return False
    import random
    hash_str = "%016x" % random.getrandbits(64)
    image = {}
    image[c.name] = name
    image['oldname'] = ""
    image[c.hash] = hash_str
    image[c.parent] = parent
    image[c.children] = []
    image['comment'] = ""
    image[c.deps] = deps
    image['rdeps'] = []
    image[c.image_type] = type
    image[c.time] = datetime.today().strftime(c.time_format)
    if type != "dir":
        image['path'] = path
        g_log.info("sha1 %s now." % (path))
        sha1obj = hashlib.sha1()
        sha1obj.update(open(path, 'rb').read())
        image['sha1'] = sha1obj.hexdigest()
        image['size'] = os.stat(path).st_size
    else:
        path = os.path.join(get_config(env.backup_unionfsdir), hash_str)
        image['path'] = path
        if not os.path.exists(path):
            run_cmd_root("mkdir -p %s" % path)
    g_images[hash_str] = image
    if parent is not None:
        pimage = get_backup(parent)
        pimage[c.children].append(hash_str)
    save_json_config(get_config(env.image_config), g_images)
    if name != '':
        g_image_names[name] = image


def mount_image(image, outpath=''):
    ret = False
    hash = image[c.hash]
    if has_mounted(hash):
        g_log.warning("backup: %s is mounted." % (name))
        return False
    new_image = {}
    inpath = image['path']
    imgtype = image[c.image_type]
    new_image[c.name] = image[c.name]
    new_image['oldname'] = image['oldname']
    new_image[c.parent] = image[c.parent]
    new_image[c.hash] = hash
    new_image[c.deps] = image[c.deps]
    new_image['inpath'] = inpath
    new_image[c.opath] = outpath
    new_image[c.by] = []
    new_image[c.used] = []
    new_image[c.image_type] = imgtype
    new_image[c.time] = datetime.today().strftime(c.time_format)
    new_image[c.mount_mode] = ""
    global g_images_dir
    if not os.path.exists(outpath):
        if not run_cmd_root("mkdir -p %s" % outpath):
            return False
    if imgtype in [c.sfs, c.iso, 'ext3', 'ext4']:
        cmd = "mount %s %s" % (inpath, outpath)
        if run_cmd_root(cmd):
            # new_image[c.cmd] = cmd
            new_image[c.status] = c.mounted
            if imgtype in [c.sfs, c.iso]:
                new_image[c.mount_mode] = "ro"
            else:
                new_image[c.mount_mode] = "rw"
            g_images_dir[hash] = new_image
            save_mounted_config(mounted=True)
            ret = True
    elif imgtype in ['tar', 'tar.gz', 'tgz', 'tar.bz2']:
        cmd = "tar xvf %s -C %s" % (inpath, outpath)
        if run_cmd_root(cmd):
            # new_image[c.cmd] = cmd
            new_image[c.status] = c.extract
            g_images_dir[hash] = new_image
            save_mounted_config(extract=True)
            ret = True
    elif imgtype in [c.dir]:
        paths = []
        while True:
            name = image[c.parent]
            if name == None:
                break
            image = get_backup(name)
            hash = image[c.hash]
            m_image = g_images_dir[hash]
            m_image[c.by].append(new_image[c.hash])
            new_image[c.used].append(hash)
            paths.append(m_image[c.opath])
        upperdir = os.path.join(inpath, "upper")
        workdir = os.path.join(inpath, "work")
        if not os.path.exists(upperdir):
            run_cmd_root("mkdir -p %s" % upperdir)
        if not os.path.exists(workdir):
            run_cmd_root("mkdir -p %s" % workdir)
        mount_opt = "lowerdir=%s,upperdir=%s,workdir=%s" % (':'.join(paths), upperdir, workdir)
        cmd = "mount -t overlay -o %s overlay %s" % (mount_opt, outpath)
        if run_cmd_root(cmd):
            new_image[c.status] = c.mounted
            # new_image[c.cmd] = cmd
            new_image[c.mount_mode] = "rw"
            g_images_dir[new_image[c.hash]] = new_image
            save_mounted_config(mounted=True)
            ret = True
    return ret


def remove_backup(backup_name):
    if not has_backup(backup_name):
        g_log.error("remove backup error: %s is not exist." % (backup_name))
        return False
    image = get_backup(backup_name)
    if image[c.name] != '':
        backup_name = image[c.name]
        image['oldname'] = backup_name
        image[c.name] = ''
        del g_image_names[backup_name]
    pimage = get_backup(image[c.parent])
    if pimage is not None:
        pimage[c.children].remove(image[c.hash])
    save_json_config(get_config(env.image_config), g_images)


def mksquashfs(dir, path, exclude=(), comp='lzo', other=()):
    if os.path.exists(path):
        g_log.error("mksquashfs: %s is exist." % (path))
        return False
    other_param = ' '.join([p for p in other] + ['-noappend'])
    exclude_param = ' '.join(["-e '%s'" % (e) for e in exclude])
    cmd = "mksquashfs %s %s -comp %s %s -regex %s" % (dir, path, comp, other_param, exclude_param)
    return run_cmd_root(cmd)


def create_backup_cmd(arg):
    deps = ()
    temps = get_config(env.backup_deps, None)
    if temps != None:
        deps = tuple(temps.split(','))
    parent = get_config(env.backup_parent, None)
    if os.path.exists(arg):
        name = get_config(env.backup_name, os.path.basename(arg))
        create_backup(name, arg, parent, deps)
    else:
        image = get_backup(arg)
        if image is not None:
            name = get_config(env.backup_name, image[c.name])
            if image[c.image_type] != c.sfs:
                g_log.error(str.format("can't create backup on {0}, {0} must be type sfs", name))
                return
            if parent is not None:
                g_log.warn("ignore --backup-parent param")
            create_backup(name, parent=image[c.hash])


def get_image_content_path(image):
    return os.path.join(image['path'], 'upper')


def compact_backup(name):
    image = get_backup(name)
    if image[c.image_type] != c.dir:
        g_log.error("image must be a directory type")
        return
    exclude = get_config(env.exclude, ())
    backup_name = get_config(env.backup_name, image[c.name])
    if has_backup(backup_name):
        g_log.warn("%s is exist" % backup_name)
        remove_backup(backup_name)
    backup_file = get_newbackup_path(backup_name)
    if not mksquashfs(get_image_content_path(image), backup_file, exclude):
        g_log.error("mksquashfs %s error." % backup_file)
        return False
    add_image_config(backup_name, backup_file, c.sfs, parent=image[c.parent], deps=image[c.deps])


def get_newbackup_path(name):
    tmstr = datetime.today().strftime("%y%m%d_%H%M%S")
    backup_rootdir = get_config(env.backup_rootdir)
    if not os.path.exists(backup_rootdir):
        run_cmd_root("mkdir -p %s" % backup_rootdir)
    return os.path.join(backup_rootdir, "%s_%s.sfs" % (name, tmstr))


def create_backup(name='', dir="", parent=None, deps=()):
    type = c.sfs
    if parent == None:
        if has_backup(name):
            g_log.info("backup %s is exist." % (name))
        dir = dir.rstrip('/')
        if not os.path.exists(dir):
            g_log.error(dir + " not exist.")
            sys.exit(1)
        backup_file = get_newbackup_path(name)
        if os.path.exists(backup_file):
            g_log.error("%s is exist, can't create backup." % (backup_file))
            return False
        exclude = get_config(env.exclude, ())
        if not mksquashfs(dir, backup_file, exclude):
            g_log.error("mksquashfs %s error." % (backup_file))
            return False
    else:
        type = c.dir
        backup_file = dir
        pimage = get_backup(parent)
        if pimage[c.image_type] == c.dir:
            g_log.error("parent image can't be directory")
            return False
        if name is '':
            name = pimage[c.name]
    if has_backup(name):
        remove_backup(name)
    add_image_config(name, backup_file, type, parent=parent, deps=deps)
    return True


def add_backup(bakfile):
    pass


def get_parent_list(name):
    paths = []
    while True:
        image = get_backup(name)
        paths.append(image[c.hash])
        name = image[c.parent]
        if name == None:
            break
    # paths.reverse()
    return paths


def mount_backup(name, mode='rw'):
    image = get_backup(name)
    if image is None:
        g_log.warning("backup: %s is not exist." % (name))
        return False
    if not check_backup(name):
        return False
    hash = image[c.hash]
    if has_mounted(hash, mode):
        g_log.warning("backup: %s is mounted." % (name))
        return True
    g_log.info("mount backup %s:%s" % (name, mode))
    ret = True
    mounted_deps = []
    for n in image[c.deps]:
        if mount_backup(n):
            mounted_deps.append(n)
        else:
            for d in mounted_deps:
                umount_backup(d)
            ret = False
            break

    if ret:
        parent = image[c.parent]
        if parent != None:
            ret = mount_backup(parent, mode='ro')

    if ret:
        if mode == 'ro':
            tempdir = os.path.join(get_config(env.backup_tempdir), hash)
            if not os.path.exists(tempdir):
                run_cmd_root("mkdir -p %s" % tempdir)
            ret = mount_image(image, tempdir)
        if mode == 'rw':
            if image[c.image_type] != c.dir:
                if not create_backup(parent=hash):
                    return False
                mount_backup(hash, 'ro')
                image = get_backup(name)
            workdir = os.path.join(get_config(env.backup_workdir), image[c.name])
            ret = mount_image(image, workdir)

    return ret


def umount_backup(name):
    hash = get_backup(name)[c.hash]
    if not has_mounted(hash):
        g_log.warning("backup: %s is not mounted." % (name))
        return False
    ret = False
    m_image = g_images_dir[hash]
    parent = m_image[c.parent]
    for n in m_image[c.deps][::-1]:
        umount_backup(n)
        m_image[c.deps].pop(0)
    if len(m_image[c.deps]) != 0:
        g_log.error("deps is not none, can't umount %s " % name)
        return ret
    if len(m_image[c.by]) != 0:
        by_names = ','.join([pretty_name(n) for n in m_image[c.by]])
        g_log.info("%s used by %s" % (pretty_name(name), by_names))
        return ret
    path = m_image[c.opath]
    if run_cmd_root("umount %s" % (path)):
        run_cmd_root("rmdir %s" % (path))
        del g_images_dir[hash]
        for m_hash in m_image[c.used]:
            g_images_dir[m_hash][c.by].remove(hash)
        save_mounted_config(mounted=True)
        ret = True
    if parent != None:
        ret = umount_backup(parent)
    return ret


def run_option(o, p, t="config"):
    opt = g_config['opt'][o]
    if opt[c.image_type] != t:
        return
    #  print("%s = %s" % (o, p))
    if p is '?':
        print(o + ' help:')
        print("%s" %(opt['help']))
        show_map_1level(opt['values'], "  ")
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

    set_config(env.backup_tempdir, "/media/backup.temp")
    # set_config(env.backup_rootdir, "/media/backup")
    set_config(env.backup_rootdir, "/tmp/zmbak")
    # set_config(env.backup_unionfsdir, "/media/backup/unionfs")
    set_config(env.backup_unionfsdir, "/media/backup.unionfs")
    # set_config(env.backup_workdir, "/media/bak/")
    set_config(env.backup_workdir, "/media/backup.work")

    # set_config(env.image_config, "/media/backup/image.json")
    # set_config(env.mounted_config, "/tmp/.mounted.json")
    # set_config(env.extract_config, "/media/backup.temp/extract.json")
    set_config(env.image_config, "image.json")
    set_config(env.mounted_config, "mounted.json")
    set_config(env.extract_config, "extract.json")


def which(file):
    for path in os.environ["PATH"].split(os.pathsep):
        if os.path.exists(os.path.join(path, file)):
            return True
    return False


def run_cmd(cmd):
    g_log.info('cmd: ' + cmd)
    p = subprocess.Popen(cmd, bufsize=0, stdout=sys.stdout, stderr=sys.stderr, shell=True)
    p.wait()
    if p.returncode != 0:
        g_log.error('return %d' % (p.returncode))
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
            g_log.error("can't find sudo or su, you must use root.")
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
    show_map_1level(map_help, "  ")
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
    g_log = mmlog.getLogger("zm.log", showFunc=True)
    g_log.setLevel(logging.NOTSET)
    init_config()
    init_options()
    init_image_config()
    init_mounted_config()
    proc_options()
    # run_cmd("cat /proc/mounts | awk '{print $2}'")
