# Create a new directory and enter it
md() {  mkdir -p "$@" && cd "$@"; }
# find shorthand
f() { find . -name "$@"; }
# ff:  to find a file under the current directory
ff() { find . -type f -name "$@" ; }
# ffs: to find a file whose name starts with a given string
ffs() { find . -type f -name "$@"'*' ; }
# ffe: to find a file whose name ends with a given string
ffe() { find . -type f -name '*'"$@" ; }
# ff:  to find a file under the current directory
fdir() { find . -type d -name "$@" ; }

pretty() { pygmentize -f terminal256 $* | less -R; }

command_exists() { type "$1" > /dev/null 2>&1; }

upto () {
    [ -z "$1" ] && return
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


# get gzipped size
gz() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# All the dig info
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
unidecode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    echo # newline
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

# Start an HTTP server from a directory, optionally specifying the port
SimpleHTTPServer() {
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# syntax highlight the contents of a file or the clipboard and place the result on the clipboard
hl() {
    local src
    local style="$2"
    local cbPasteStr
    local cbCopyStr

    [ -z "$style" ] && style="moria"

    case "$OSTYPE" in
      darwin*)
        cbPasteStr='pbpaste'
        cbCopyStr='pbcopy'
        ;;
      linux*)
        cbPasteStr="xclip -o"
        cbCopyStr="xclip -i"
        ;;
      *)
        echo "Platform $OSTYPE not supported"
                return 1
        ;;
    esac

    if [ -n "$3" ]; then
        src=$( cat $3 )
    else
        src=$( $cbPasteStr )
    fi

    echo $src | highlight -O rtf --syntax $1 --font Inconsoloata --style $style --line-number --font-size 24 | $cbCopyStr
}

most_used_in_history() {
    h | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

if [[ "$OSTYPE" == darwin* ]]; then
ng-stop() {
    sudo launchctl stop homebrew.mxcl.nginx
}

ng-start() {
    sudo launchctl start homebrew.mxcl.nginx
}
ng-restart() {
     sudo launchctl start homebrew.mxcl.nginx
}

dns-restart() {
    sudo launchctl stop homebrew.mxcl.dnsmasq
    sudo launchctl start homebrew.mxcl.dnsmasq
}
fi

if [ "$CURRENT_SHELL" = "bash" ]; then
    complete -F _upto upto
fi
