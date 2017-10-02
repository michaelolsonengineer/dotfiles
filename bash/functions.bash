####################
# functions
####################

# print available colors and their numbers
function colours() {
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
function f() {
    find . -name "$1"
}

pretty() {
    pygmentize -f terminal256 $* | less -R
}

# take this repo and copy it to somewhere else minus the .git stuff.
function gitexport(){
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
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