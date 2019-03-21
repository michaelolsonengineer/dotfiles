#!/bin/bash

# ------------------------------------
# Docker alias and function
# ------------------------------------

docker_alias() {
    docker run \
        --rm \
        --interactive \
        --tty \
        --workdir $1 \
        --publish 3000:3000 \
        --publish 8080:8080 \
        --publish 8000:8000 \
        --publish 80:80 \
        --publish 3306:3306 \
        --publish 27017:27017 \
        --publish 8888:8888 \
        --volume $(pwd):$1 \
        ${@:2}
}

dbash() {
    docker run \
        --rm \
        --interactive \
        --tty \
        --env TERM=xterm-256color \
        --volume ~/.ssh:/var/shared/.ssh \
        --volume ~/.bash_history:/var/shared/.bash_history \
        --volume ~/.subversion:/var/shared/.subversion \
        --volume ~/.gitconfig:/var/shared/.gitconfig \
        --volume ~/.dotfiles:/var/shared/.dotfiles \
        --volume ~/.vim_runtime:/var/shared/.vim_runtime \
        --entrypoint /bin/bash \
        --volume $(pwd):/var/shared/build_code \
        $@
}

# Stop all containers
dstopa() { docker stop $(docker ps -a -q); }

# Remove all containers
dkrma() { docker rm $(docker ps -a -q); }

# Remove all images
dkri() { docker rmi $(docker images -q); }

# Dockerfile build, e.g., $dbu tcnksm/test 
dkbuild() { docker build -t=$1 .; }

# Show all alias related docker
dkalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Bash into running container
dkenter() { docker exec -it $(docker ps -aqf "name=$1") bash; }

# # JavaScript / CoffeeScript
# alias node="docker_alias /directory node node"
# alias npm="docker_alias /directory node npm"
# alias coffee="docker_alias /directory shouldbee/coffeescript coffee"

# # PHP
# alias php="docker_alias /directory php php"

# # Ruby
# alias ruby="docker_alias /directory ruby ruby"

# alias rails="docker_alias /directory rails rails"
# alias rake="docker_alias /directory rails rake"

# # Python
# alias python2.7="docker_alias /directory python:2.7 python"
# alias python="docker_alias /directory python python"

# alias django-admin.py="docker_alias /directory django django-admin.py"

# # Redis
# alias redis-cli="docker_alias /directory redis redis-cli"
# alias redis-server="docker_alias /directory redis redis-server"

# alias redis-benchmark="docker_alias /directory redis redis-benchmark"
# alias redis-check-dump="docker_alias /directory redis redis-check-dump"
# alias redis-check-aof="docker_alias /directory redis redis-check-aof"
# alias redis-sentinel="docker_alias /directory redis redis-sentinel"

# # MongoDB
# alias mongo="docker_alias /directory mongo mongo"
# alias mongod="docker_alias /directory mongo mongod"

# # Postgres
# alias postgres="docker_alias /directory postgres postgres"
# alias psql="docker_alias /directory postgres psql"

# alias pg_dump="docker_alias /directory postgres pg_dump"
# alias pg_dumpall="docker_alias /directory postgres pg_dumpall"
# alias pg_restore="docker_alias /directory postgres pg_restore"

# # Nginx
# alias nginx="docker_alias /usr/share/nginx/html nginx nginx"

# # LAMP
# alias lamp-here="docker_alias /var/www/html tutum/lamp"

alias dkatt='docker attach'
alias dkcb='docker-compose build'
alias dkclogs='docker-compose logs'
alias dkcu='docker-compose up'
alias dkdiff='docker diff'
alias dkimg='docker images'
alias dkins='docker inspect'
alias dkps='docker ps'
alias dkrm='docker rm'
alias dkrmi='docker rmi'
alias dkrun='docker run'
alias dkstart='docker start'
alias dkstop='docker stop'

# Get latest container ID
alias dkl="docker ps -l -q"

# Get container process
alias dkps="docker ps"

# Get process included stop container
alias dkpa="docker ps -a"

# Get images
alias dki="docker images"

# Get container IP
alias dkip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# Run deamonized container, e.g., $dkd base /bin/echo hello
alias dkd="docker run -d -P"

# Run interactive container, e.g., $dki base /bin/bash
alias dki="docker run -i -t -P"

alias dkls='
echo "== docker images =="
docker images
echo -e "\n== docker volume ls =="
docker volume ls
echo -e "\n== docker container ls =="
docker container ls
echo -e "\n== docker service ls =="
docker service ls
echo -e "\n== docker ps -a =="
docker ps -a
'

# Credit to <https://gist.github.com/bastman/5b57ddb3c11942094f8d0a97d461b430#remove-docker-images>
alias dkclimg='docker rmi --force $(docker images --filter "dangling=true" -q --all --no-trunc)'
alias docker_clean='docker rmi --force $(docker images --filter "dangling=true" -q --all --no-trunc)'

# Credit to <https://stackoverflow.com/a/21928864/37776>
alias dkrestartf='docker start $(docker ps -ql) && docker attach $(docker ps -ql)'

# Stop and Remove all containers
alias dkrmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

