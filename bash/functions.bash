####################
# functions
####################

# is x grep argument available?
grep-flag-available() {
    echo | grep $1 "" >/dev/null 2>&1
}

grp() {
    local GREP_OPTIONS=""
    local VCS_FOLDERS="{.bzr,.cvs,.git,.hg,.svn}"
    local TEMP_FOLDERS="{tmp,bin,build,dist,nto,arm}"
    local DATA_FILES="{tags,cscope.out,cctree.out}"
    local VERSION_FILES="\*.{0,1,2}"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

    if grep-flag-available --exclude-dir=.cvs; then
        GREP_OPTIONS+=" --exclude-dir=$VCS_FOLDERS"
        GREP_OPTIONS+=" --exclude-dir=$TEMP_FOLDERS"
    elif grep-flag-available --exclude=.cvs; then
        GREP_OPTIONS+=" --exclude=$VCS_FOLDERS"
        GREP_OPTIONS+=" --exclude=$TEMP_FOLDERS"
    fi

    if grep-flag-available --exclude=tags; then
        GREP_OPTIONS+=" --exclude=$DATA_FILES"
        GREP_OPTIONS+=" --exclude=$VERSION_FILES"
    fi

    /bin/grep \
        --recursive \
        --binary-files=without-match \
        --line-number \
        --with-filename \
        $GREP_OPTIONS \
        $@
}

command_exists() {
    type "$1" > /dev/null 2>&1
}

open_command() {
  local open_cmd

  # define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   if ! [[ $(uname -a) =~ "Microsoft" ]]; then
                open_cmd='xdg-open' 
              else
                open_cmd='cmd.exe /c start ""'
                if [ -e "$1" ]; then 
                    1="$(wslpath -w "${1:a}")" || return 1 
                fi
              fi
              ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac

  # don't use nohup on OSX
  if [ "$OSTYPE" == darwin* ]; then
    $open_cmd "$@" &>/dev/null
  else
    nohup $open_cmd "$@" &>/dev/null
  fi
}

alias o='open_command'

# print available colors and their numbers
colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (( $i % 5 == 0 )); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

# find shorthand
f() { find . -name "$@"; }
# ff:  to find a file under the current directory
ff() { find . -name "$@" ; }
# ffs: to find a file whose name starts with a given string
ffs() { find . -name "$@"'*' ; }
# ffe: to find a file whose name ends with a given string
ffe() { find . -name '*'"$@" ; }

pretty() {
    pygmentize -f terminal256 $* | less -R
}

# take this repo and copy it to somewhere else minus the .git stuff.
gitexport() {
    local directory=$1
    local branch=${2:master}
    mkdir -p "$directory"
    git archive $branch | tar -x -C "$directory"
}

upto () {
    if [ -z "$1" ]; then
        return
    fi
    local upto=$1
    cd "${PWD/\/$upto\/*//$upto}"
}

_upto() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local d=${PWD//\//\ }
    COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}

jd() {
    if [ -z "$1" ]; then
        echo "Usage: jd [directory]";
        return 1
    else
        cd **"/$1"
    fi
}

up() {
    ups=""
    for i in $(seq 1 $1); do
        ups=$ups"../"
    done
    cd $ups
}

if [ "$CURRENT_SHELL" = "bash" ]; then
    complete -F _upto upto
fi

# open archive and extract contents
extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1     ;;
             *.tar.gz)    tar xzf $1     ;;
             *.tar.xz)    tar xJf $1     ;;
             *.bz2)       bunzip2 $1     ;;
             *.rar)       rar x $1       ;;
             *.gz)        gunzip $1      ;;
             *.tar)       tar xf $1      ;;
             *.tbz2)      tar xjf $1     ;;
             *.tgz)       tar xzf $1     ;;
             *.zip)       unzip $1       ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1        ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# zipf: to create a ZIP archive of a file or folder
zipf() {
    zip -r "$1".zip "$1" ;
}

clean-ssh() {
    local sshHomeDir=$HOME/.ssh
    local knownHostsDir=$sshHomeDir/known_hosts
    if [ -d $sshHomeDir ]; then
        if [ -f $knownHostsDir ]
        then
            echo 'removing SSH known Hosts - printing previous contents'
            cat $knownHostsDir
            rm $knownHostsDir
            echo '.ssh directory should be cleared - printing its contents'
            ls -la $sshHomeDir
        else
            echo 'No known ssh hosts'
        fi
    fi
}

mount-cifs-dot-smbpasswd() {
    local remoteDir=$1
    local localDir=$2

    mkdir -p $localDir
    if mountpoint -q $localDir; then
        echo "$localDir is already mounted"
        cd $localDir
    else
        sudo mount -t cifs $remoteDir -o credentials=$HOME/.smbpasswd,rw,user,uid=$(whoami),gid=$(whoami) $localDir \
            && cd $localDir \
            && echo "Successfully mounted $remoteDir to $localDir"
    fi
}

mount-uuid-ntfs() {
    local uuid=$1
    local localDir=$2

    mkdir -p $localDir
    if mountpoint -q $localDir; then
        echo "$localDir is already mounted"
        cd $localDir
    else
        sudo mount -t ntfs-3g --uuid $uuid -o auto,rw,permissions $localDir \
            && cd $localDir \
            && echo "Successfully mounted UUID=$uuid to $localDir"
    fi
}
