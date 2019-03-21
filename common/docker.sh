#!/bin/bash

# ------------------------------------
# Docker alias and function
# ------------------------------------

alias dk=docker

if [ "$CURRENT_SHELL" = "bash" ]; then
    complete -F _docker dk
elif [ "$CURRENT_SHELL" = "zsh" ]; then
    compdef dk=docker
fi

# Usage:
#   docker_alias_completion_wrapper <completion function> <alias/function name>
#
# Example:
#   dock-ip() { docker inspect --format '{{ .NetworkSettings.IPAddress }}' $@ ;}
#   docker_alias_completion_wrapper __docker_complete_containers_running dock-ip
docker_alias_completion_wrapper() {
  local completion_function="$1";
  local alias_name="$2";

  local func=$(cat <<EOT
    # Generate a new completion function name
    function _$alias_name() {
        # Start off like _docker()
        local previous_extglob_setting=\$(shopt -p extglob);
        shopt -s extglob;

        # Populate \$cur, \$prev, \$words, \$cword
        _get_comp_words_by_ref -n : cur prev words cword;

        # Declare and execute
        declare -F $completion_function >/dev/null && $completion_function;

        eval "\$previous_extglob_setting";
        return 0;
    };
EOT
  );
  eval "$func";

  # Register the alias completion function
  if [ "$CURRENT_SHELL" = "bash" ]; then
        complete -F _$alias_name $alias_name
  fi 
}

if [ "$CURRENT_SHELL" = "bash" ]; then
   export -f docker_alias_completion_wrapper
fi

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

dkbash() {
    docker run \
        --rm \
        --interactive \
        --tty \
        --env TERM=xterm-256color \
	    --publish 8888:8888 \
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

dkbashp() {
    dkbash --privileged $@
}

#docker_alias_completion_wrapper __docker_complete_containers_running dkbash

dkcleanimg() {
    local dangling_images=$(docker images --filter "dangling=true" -q --no-trunc)
    if [ -n "$dangling_images" ]; then
        docker rmi $dangling_images
    fi
}

dkcleanimg() {
    local dangling_volumes=$(docker volume ls --filter 'dangling=true' -q)
    if [ -n "$dangling_volumes" ]; then
        docker volume rm $dangling_volumes
    fi
}

# Stop all containers
dkstopa() { docker stop $(docker ps -a -q); }

# Remove all containers
dkrma() { docker rm $(docker ps -a -q); }

# Remove all images
dkrmia() { docker rmi $(docker images --filter "dangling=true" -q); }

# Dockerfile build, e.g., $dbu tcnksm/test 
dkbuild() { docker build -t=$1 .; }

# Show all alias related docker
dkaliases() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Bash into running container
dkenter() { docker exec -it -v $(pwd):$1 \ $(docker ps -aqf "name=$1") bash; }

#docker_alias_completion_wrapper __docker_complete_containers_running dkenter

# # JavaScript / CoffeeScript
# alias node="docker_alias /directory node node"
# alias npm="docker_alias /directory node npm"
# alias coffee="docker_alias /directory shouldbee/coffeescript coffee"

# # PHP
# alias php="docker_alias /directory php php"

# Ruby
alias ruby="docker_alias /directory ruby ruby"

alias rails="docker_alias /directory rails rails"
alias rake="docker_alias /directory rails rake"

# # Python
# alias python2.7="docker_alias /directory python:2.7 python"
# alias python="docker_alias /directory python python"

# alias django-admin.py="docker_alias /directory django django-admin.py"

# Redis
alias redis-cli="docker_alias /directory redis redis-cli"
alias redis-server="docker_alias /directory redis redis-server"

alias redis-benchmark="docker_alias /directory redis redis-benchmark"
alias redis-check-dump="docker_alias /directory redis redis-check-dump"
alias redis-check-aof="docker_alias /directory redis redis-check-aof"
alias redis-sentinel="docker_alias /directory redis redis-sentinel"

# # MongoDB
# alias mongo="docker_alias /directory mongo mongo"
# alias mongod="docker_alias /directory mongo mongod"

# Postgres
alias postgres="docker_alias /directory postgres postgres"
alias psql="docker_alias /directory postgres psql"

alias pg_dump="docker_alias /directory postgres pg_dump"
alias pg_dumpall="docker_alias /directory postgres pg_dumpall"
alias pg_restore="docker_alias /directory postgres pg_restore"

# # Nginx
# alias nginx="docker_alias /usr/share/nginx/html nginx nginx"

# LAMP
alias lamp-here="docker_alias /var/www/html tutum/lamp"

alias dkclean='dkcleanimg; dkcleanvol'

alias dkatt='docker attach'
alias dkbuild='docker build'
alias dkdiff='docker diff'
alias dkimg='docker images'
alias dkins='docker inspect'
alias dkps='docker ps'
alias dkrm='docker rm'
alias dkrmi='docker rmi'
alias dkrun='docker run'
alias dkstart='docker start'
alias dkstop='docker stop'

alias dkcbuild='docker-compose build'
alias dkclogs='docker-compose logs'
alias dkcup='docker-compose up'

docker_alias_completion_wrapper __docker_complete_images dkrmi
docker_alias_completion_wrapper __docker_complete_images dkrun

docker_alias_completion_wrapper __docker_complete_containers_running dkatt
docker_alias_completion_wrapper __docker_complete_containers_running dkins
docker_alias_completion_wrapper __docker_complete_containers_stoppable dkstop

docker_alias_completion_wrapper __docker_complete_containers_removable dkrm
docker_alias_completion_wrapper __docker_complete_containers_unpauseable dkstart

# Get latest container ID
alias dklast="docker ps -l -q"

# Get container process
alias dkps="docker ps"

# Get all processes including stop containers
alias dkpa="docker ps -a"

# Get images
alias dki="docker images"

# Get container IP
alias dkip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
#__docker_complete_containers_running dkip

# Run deamonized container, e.g., $dkd base /bin/echo hello
alias dkd="docker run -d -P"
#__docker_complete_containers_running dkd

# Run interactive container, e.g., $dki base /bin/bash
alias dki="docker run -i -t -P"
#__docker_complete_containers_running dki

alias dkls='
echo "== docker images =="
docker images
echo -e "\n== docker volume ls =="
docker volume ls
echo -e "\n== docker container ls =="
docker container ls
echo -e "\n== docker ps -a =="
docker ps -a
'

# Credit to <https://stackoverflow.com/a/21928864/37776>
alias dkrestartf='docker start $(docker ps -ql) && docker attach $(docker ps -ql)'
#__docker_complete_containers_running dkrestartf

# Stop and Remove all containers
alias dkrmfa='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

alias dkkillall="docker ps -q | xargs docker kill"
