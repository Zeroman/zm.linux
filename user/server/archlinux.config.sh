#!/bin/bash -

zm_add_softs()
{
    add_soft base-devel
    add_soft docker
    add_soft docker-compose
    add_soft docker-machine
    add_soft docker-buildx
    add_soft python-docker
    add_soft python-colorama
}

_disable_service()
{
    $SUDO systemctl stop $1 || true
    $SUDO systemctl disable $1 || true
}

_setup_locale()
{
    $SUDO sed -i 's/#\(zh_CN.*$\)/\1/g' /etc/locale.gen
    $SUDO sed -i 's/#\(en_US.*$\)/\1/g' /etc/locale.gen
    $SUDO locale-gen
    $SUDO localectl set-locale LANG=en_US.UTF-8
}

_setup_docker()
{
    #_disable_service docker
    $SUDO rm -rf /var/lib/docker
    $SUDO ln -s /work/docker/data /var/lib/docker
    #graph_opt='--graph /work/docker/data -s overlay2'
    #mirror_opt='--registry-mirror=https://docker.mirrors.ustc.edu.cn'
    #$SUDO sed -i 's#--graph .*$##g' /usr/lib/systemd/system/docker.service
    #$SUDO sed -i "s#\(ExecStart.*$\)#\1 $graph_opt $mirror_opt#g" /usr/lib/systemd/system/docker.service
    #$SUDO systemctl daemon-reload
    echo "$zm_user ..."
    $SUDO usermod -a -G docker $zm_user || true
    mkdir -p $zm_user_home/.docker
    echo '{
    "detachKeys": "ctrl-q,q"
}
' > $zm_user_home/.docker/config.json
    #$SUDO systemctl restart docker || true
}

zm_setup()
{
    need_root
    
    zm_setup_tzdata 'Asia' 'Hong_Kong'
    zm_setup_user
    
    _setup_locale
    _setup_docker
}

