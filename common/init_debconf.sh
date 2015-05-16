#!/bin/sh

# export LANG=zh_CN.UTF-8
# export DEBCONF_DEBUG=developer
#Dialog, Readline, Gnome, Kde, Editor, Noninteractive
# export DEBIAN_FRONTEND=Gnome 

PATH=$PATH:.
if [ -e confmodule ]; then
    . confmodule
else
    . /usr/share/debconf/confmodule
fi
db_version 2.0
db_capb escape
db_settitle zm_debconf/title
# db_info zm_debconf/info  

