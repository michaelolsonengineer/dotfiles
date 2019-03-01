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

# md: Create a new directory and enter it
md() {  mkdir -p "$@" && cd "$@"; }

# f: find shorthand
f() { find . -name "$@"; }

# ff:  to find a file under the current directory
ff() { find . -type f -name "$@" ; }

# ffs: to find a file whose name starts with a given string
ffs() { find . -type f -name "$@"'*' ; }

# ffe: to find a file whose name ends with a given string
ffe() { find . -type f -name '*'"$@" ; }

# ff:  to find a file under the current directory
fdir() { find . -type d -name "$@" ; }

# pprintf: output file to less with syntax coloring
pprintf() { pygmentize -f terminal256 $* | less -R; }

# command_exists: check if command exists
command_exists() { type "$1" > /dev/null 2>&1; }

# upto: go up to the specified directory
upto () {
    [ -z "$1" ] && return
    local upto=$1
    cd "${PWD/\/$upto\/*//$upto}"
}

# _upto: used for bash completion
_upto() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local d=${PWD//\//\ }
    COMPREPLY=( $( compgen -W "$d" -- "$cur" ) )
}

# jd: jump to specified parent directory
jd() {
    if [ -z "$1" ]; then
        echo "Usage: jd [directory]";
        return 1
    else
        cd **"/$1"
    fi
}

# up: go to the parent directory specified number ($1) times 
up() {
    ups=""
    for i in $(seq 1 $1); do
        ups=$ups"../"
    done
    cd $ups
}

# extract: open archive and extract contents
extract () {
  local archive=$1
  local outputDir=$2
  local cwd=`pwd`
  
  if [ -f $archive ] ; then
    if [ -n "$outputDir" ]; then
      mkdir -p $outputDir
      cp $archive $outputDir
      cd $outputDir
    fi

     case $archive in
         *.tar.bz2)   tar xjf $archive     ;;
         *.tar.gz)    tar xzf $archive     ;;
         *.tar.xz)    tar xJf $archive     ;;
         *.bz2)       bunzip2 $archive     ;;
         *.rar)       rar x $archive       ;;
         *.gz)        gunzip $archive      ;;
         *.tar)       tar xf $archive      ;;
         *.tbz2)      tar xjf $archive     ;;
         *.tgz)       tar xzf $archive     ;;
         *.zip)       unzip $archive       ;;
         *.Z)         uncompress $archive  ;;
         *.7z)        7z x $archive        ;;
         *)           echo "'$archive' cannot be extracted via extract()" ;;
     esac

    if [ -n "$outputDir" ]; then
      rm -f $outputDir/$archive
      cd $cwd
    fi
  else
     echo "'$archive' is not a valid file"
  fi 
}

# zipf: to create a ZIP archive of a file or folder
zipf() {
    zip -r "$1".zip "$1" ;
}

# get gzipped size comparison
gzsizecmp() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# digga: All the dig info on IP or URL
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
escapeunicode() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
decodeunicode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    echo # newline
}

mount-cifs-dot-smbpasswd() {
    local remoteDir=$1
    local localDir=$2
    local credentials=$HOME/.smbpasswd
    local mountOptions="rw,user,uid=$(whoami),gid=$(whoami)"
    [ -f "$credentials" ] && mountOptions="credentials=$credentials,$mountOptions"

    mkdir -p $localDir
    if mountpoint -q $localDir; then
        echo "$localDir is already mounted"
        cd $localDir
    else
        sudo mount -t cifs $remoteDir -o $mountOptions $localDir \
            && cd $localDir \
            && echo "Successfully mounted $remoteDir to $localDir"
    fi
}

mount-uuid-ntfs() {
    local uuid=$1
    local localDir=$2
    local mountOptions="auto,rw,permissions"

    mkdir -p $localDir
    if mountpoint -q $localDir; then
        echo "$localDir is already mounted"
        cd $localDir
    else
        sudo mount -t ntfs-3g --uuid $uuid -o $mountOptions $localDir \
            && cd $localDir \
            && echo "Successfully mounted UUID=$uuid to $localDir"
    fi
}

# SimpleHTTPServer: Start an HTTP server from a directory, optionally specifying the port
SimpleHTTPServer() {
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
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

fi

if [ "$CURRENT_SHELL" = "bash" ]; then
    complete -F _upto upto
fi
