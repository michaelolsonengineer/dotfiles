#--------------------------------------------
# Preliminary:
#--------------------------------------------

export CURRENT_SHELL=$(ps -p $$ | awk '$1 == PP {print $4}' PP=$$)

if [ "$CURRENT_SHELL" = "bash" ]; then
   alias reshell="source ${HOME}/.bashrc"
elif [ "$CURRENT_SHELL" = "zsh" ]; then
   alias reshell="source ${HOME}/.zshrc"
elif [ "$CURRENT_SHELL" = "ash" ]; then
   alias reshell="source ${HOME}/.ashrc"
fi

# show environment path
alias path="echo -e ${PATH//:/\\\\n}"

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color=auto"
else # OS X `ls`
    colorflag="-G"
fi

alias c='clear'

alias h='history'
[ "$CURRENT_SHELL" = zsh ] && alias h='history 0'

# Alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(h |tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias pyg='pygmentize'
alias kitten='pyg -g'

#--------------------------------------------
# Aliases and this file:
#--------------------------------------------

alias ralias="source $HOME/.aliases.sh"

# showa: to remind yourself of an alias (given some part of it)
showa() { grep -i -a1 $@ $HOME/.aliases.sh | grep -v '^\s*$' ; }

# sourcea: to source this file (to make changes active after editing)
alias sourcea="ralias"

#-----------
# Searching:
#-----------

# color grep results
GREP_OPTIONS="$colorflag "

if echo | grep --exclude-dir=.cvs "" >/dev/null 2>&1; then
    GREP_OPTIONS+="--exclude-dir={\.bzr,\.cvs,\.git,\.hg,\.svn} "
elif echo | grep --exclude=.cvs "" >/dev/null 2>&1; then
    GREP_OPTIONS+="--exclude={\.bzr,\.cvs,\.git,\.hg,\.svn} "
fi

# export grep settings
alias grep="grep $GREP_OPTIONS"


# grepfind: to grep through files found by find, e.g. grepf pattern '*.c'
# note that 'grep -r pattern dir_name' is an alternative if want all files
grepfind() {
    [ -z "$3" ] && find . -type f -name "$2" -print0 | xargs -0 grep -n "$1";
    [ -n "$3" ] && find "$3" -type f -name "$2" -print0 | xargs -0 grep -n "$1";
}
# I often can't recall what I named this alias, so make it work either way:
alias findgrep='grepfind'

# grepincl: to grep through the /usr/include directory
grepincl() { (cd /usr/include; find . -type f -name '*.h' -print0 | xargs -0 grep "$1" ) ; }

# locatemd: to search for a file using Spotlight's metadata
locatemd() { mdfind "kMDItemDisplayName == '$@'wc"; }

# locaterecent: to search for files created since yesterday using Spotlight
# This is an illustration of using $time in a query
# See: http://developer.apple.com/documentation/Carbon/Conceptual/SpotlightQuery/index.html
locaterecent() { mdfind 'kMDItemFSCreationDate >= $time.yesterday'; }

# list_all_apps: list all applications on the system
list_all_apps() { mdfind 'kMDItemContentTypeTree == "com.apple.application"c' ; }

# find_larger: find files larger than a certain size (in bytes)
find_larger() { find . -type f -size +${1}c ; }

# an example of using Perl to search Unicode files for a string:
# find /System/Library -name Localizable.strings -print0 | xargs -0 perl -n -e 'use Encode; $_ = decode("utf16be", $_); print if /compromised/
# but note that it might be better to use 'iconv'

# example of using the -J option to xargs to specify a placeholder:
# find . -name "*.java" -print0 | xargs -0 -J % cp % destinationFolder

# findword: search for a word in the Unix word list
findword() { grep ^"$@"$ /usr/share/dict/words ; }

## more intelligent acking for ubuntu users
if which ack-grep &> /dev/null; then
  alias afind='ack-grep -il'
  alias acking='ACK_PAGER_COLOR="less -x4SRFX" ack-grep -a'
else
  alias afind='ack -il'
fi

alias grep="grep $colorflag"
alias fgrep="fgrep $colorflag"
alias egrep="egrep $colorflag"
alias hgrep="h | grep $colorflag"

#------------------------------
# Terminal & shell management:
#------------------------------

# fix_stty: restore terminal settings when they get completely screwed up
alias fix_stty='stty sane'

# cic: make tab-completion case-insensitive
alias cic='set completion-ignore-case On'

# show_options: display bash options settings
alias show_options='shopt'

alias reboot='echo "Please use reboot_linux as this has been aliased to prevent accidental reboot"'
alias reboot_linux='/sbin/reboot'

alias machine="echo you are logged in to ... `uname -a | cut -f2 -d' '`"

alias clearx="echo -e '\\0033\\0143'"
alias clear='printf "\\033c"'

#--------------------------
# File & folder management:
#--------------------------

## Colorize the ls output ##
alias ls="ls $colorflag"

## Use long listing format ##
alias ll="ls -alF $colorflag"
alias la="ls -A $colorflag"
alias l.="ls -d .* $colorflag"       # Show hidden files only
alias l="ls -CF $colorflag"
alias lll="ll | less"                # Put output in less editor
alias llf="ll | grep '^[-l]'"        # Show soft links only
alias lld="ll | grep ^d $colorflag"  # Show directories only

## get rid of command not found ##
alias cd..='cd ..'

## a quick way to get out of current directory ##
alias .1='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# directory-size-date
alias dsd="ls -FlAh"
alias dsdl="dsd | less"
# show directories only
alias dsdd="dsd | grep :*/"
# show executables only
alias dsdx="dsd | grep \*"
# show non-executables
alias dsdnx="dsd | grep -v \*"
# order by date
alias dsdt="dsd -tr"
# dsd plus sum of file sizes
alias dsdz="dsd $1 $2 $3 $4 $5 | awk '{ print; x=x+\$5 } END { print \"total bytes = \",x }'"
# only file without an extension
alias noext='dsd | egrep -v "\.|/"'

# numFiles: number of (non-hidden) files in current directory
alias numFiles='echo $(ls -1 | wc -l)'

# showTimes: show the modification, metadata-change, and access times of a file
showTimes() { stat -f "%N:   %m %c %a" "$@" ; }

# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'

# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

grab() {
	sudo chown -R $USER ${1:-.}
}

#-----------
# Diffing:
#-----------

alias bc='bc -l'

# install  colordiff package :)
alias diff='colordiff'

# handy short cuts #
alias j='jobs -l'

#-----------
# Time:
#-----------

alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias today='nowdate'

#-----------
# Editors:
#-----------

alias edit='subl'

# Set vim as default
alias vi='vim'
alias svi='sudo vi'
alias vis='vim "+set si"'

# edit multiple files split horizontally or vertically
alias evi="vim -o "
alias Evi="vim -O "

#-----------
# Media:
#-----------

## play video files in a current directory ##
# cd ~/Download/movie-name
# playavi or vlc
alias playavi='mplayer *.avi'
alias vlc='vlc *.avi'

# play all music files from the current directory #
alias playwave='for i in *.wav; do mplayer "$i"; done'
alias playogg='for i in *.ogg; do mplayer "$i"; done'
alias playmp3='for i in *.mp3; do mplayer "$i"; done'

# play files from nas devices #
alias nplaywave='for i in /nas/multimedia/wave/*.wav; do mplayer "$i"; done'
alias nplayogg='for i in /nas/multimedia/ogg/*.ogg; do mplayer "$i"; done'
alias nplaymp3='for i in /nas/multimedia/mp3/*.mp3; do mplayer "$i"; done'

# shuffle mp3/ogg etc by default #
alias music='mplayer --shuffle *'

#-------------
# Networking:
#-------------

# IP addresses
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias myips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"

# Stop after sending count ECHO_REQUEST packets #
alias ping='ping -c 5'
# Do not wait interval 1 second, go fast #
alias fastping='ping -c 100 -s.2'

# Show open ports
alias ports='netstat -tulanp'

# Show open TCP connections
alias checktcp='sudo lsof -i TCP'

## All of our servers eth1 is connected to the Internets via vlan / router etc  ##
wifiInterface=$(ifconfig -a | perl -nle'/(^w\w+)/ && print $1')
alias dnstop="dnstop -l 5 $wifiInterface"
alias vnstat="vnstat -i $wifiInterface"
alias iftop="iftop -i $wifiInterface"
alias tcpdump="tcpdump -i $wifiInterface"
alias ethtool="ethtool $wifiInterface"

netinfo ()
{
	local interface=${1:-wlp2s0}
	local inet=$(ifconfig $interface | awk '/inet / {print $2}')
	local broadcast=$(ifconfig $interface | awk '/broadcast / {print $6}')
	local netmask=$(ifconfig $interface | awk '/netmask / {print $4}')
	local mac=$(ifconfig $interface | awk '/ether / {print $2}')
	echo "--------------- Network Information ---------------"
	echo "IP : $inet"
	echo "Broadcast : $broadcast"
	echo "Netmask : $netmask"
	echo "MAC : $mac"
	echo "External IP : `myip`"
	echo "---------------------------------------------------"
}

#-----------
# Memory:
#-----------

## pass options to free ##
alias meminfo='free -m -l -t'

## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

## Get server cpu info ##
alias cpuinfo='lscpu'

## older system use /proc/cpuinfo ##
##alias cpuinfo='less /proc/cpuinfo' ##

## get GPU ram on desktop / laptop##
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

## this one saved by butt so many times ##
alias wget='wget -c'

## set some other defaults ##
alias df='df -H'
alias du='du -ch'

## nfsrestart  - must be root  ##
## refresh nfs mount / cache etc for Apache ##
alias nfsrestart='sync && sleep 2 && sudo /etc/init.d/httpd stop && sudo umount netapp2:/exports/http && sleep 2 && sudo mount -o rw,sync,rsize=32768,wsize=32768,intr,hard,proto=tcp,fsc natapp2:/exports /http/var/www/html && sudo /etc/init.d/httpd start'

#Grabs the disk usage in the current directory
#alias usage='du -ch | grep total'
alias usage='du -csh 2> /dev/null'
#Gets the total disk usage on your machine
alias totalusage='df -hl --total | grep total'
#Shows the individual partition usages without the temporary memory values
alias partusage='df -hlT --exclude-type=tmpfs --exclude-type=devtmpfs'
#Gives you what is using the most space. Both directories and files. Varies on
#current directory
alias most='du -hsx * | sort -rh | head -10'
# shoot the fat ducks in your current dir and sub dirs
alias ducks='du -ck | sort -nr | head'
# find larges in /home directory
alias mosthome='du -ah /home 2>/dev/null | sort -hr | head -n 10'

#-------------------------
# C/C++/Java Programming:
#-------------------------

#alias fullmake='make clean; make DEBUG=-g CCOPTS=-O0 MAKEFLAGS+=-j${NUMBER_OF_PROCESSORS} install'

# indent: C-program formatter
alias indent='indent -st'

# to find what symbols are pre-defined by the compiler
# Note that this can be done simpler via: /usr/bin/gcc -E -dM /dev/null
gcc_defines() { tmpfile="/tmp/foo$$.cpp"; echo "int main(){return 0;}" > $tmpfile; gcc -E -dM $tmpfile; rm $tmpfile ; }

# count lines of java code under the current directory
alias count_java='find . -name "*.java" -print0 | xargs -0 wc'

# count lines of C or C++ or Obj-C code under the current directory
alias count_c='find . \( -name "*.c" -or -name "*.cpp" -or -name "*.h" -or -name "*.m" \) -print0 | xargs -0 wc'

# count lines of C or C++ or Obj-C or Java code under the current directory
alias count_loc='find . \( -name "*.c" -or -name "*.cpp" -or -name "*.h" -or -name "*.m" -or -name "*.java" \) -print0 | xargs -0 wc'

#-------------------
# Perl programming:
#-------------------
# cpan: run Perl's CPAN module to get updates
alias cpan='sudo perl -MCPAN -e shell'

# testmod: test to see if a Perl module is installed. Sample usage: testmod LWP
# a possible alternative implemention: perldoc -l \!*
testmod() { perl -e "use $@" ; }

# perlsh: run Perl as a shell (for testing commands)
alias perlsh='perl -de 42'

#-----------------
# Misc Reminders:
#-----------------

# To find idle time: look for HIDIdleTime in output of 'ioreg -c IOHIDSystem'

# to set the delay for drag & drop of text (integer number of milliseconds)
# defaults write -g NSDragAndDropTextDelay -int 100

# URL for a man page (example): x-man-page://3/malloc

# to read a single key press:
alias keypress='read -s -n1 keypress; echo $keypress'

# to compile an AppleScript file to a resource-fork in the source file:
osacompile_rsrc() { osacompile -x -r scpt:128 -o $1 $1; }

# alternative to the use of 'basename' for usage statements: ${0##*/}

# graphical operations, image manipulation: sips

# numerical user id: 'id -u'
# e.g.: ls -l /private/var/tmp/mds/$(id -u)

#---------------
# Text handling:
#---------------
# fixlines: edit files in place to ensure Unix line-endings
fixlines() { perl -pi~ -e 's/\r\n?/\n/g' "$@" ; }

# cut80: truncate lines longer than 80 characters (for use in pipes)
alias cut80='cut -c 1-80'

# foldpb: make text in clipboard wrap so as to not exceed 80 characters
alias foldpb='pbpaste | fold -s | pbcopy'

# enquote: surround lines with quotes (useful in pipes) - from mervTormel
enquote() { sed 's/^/"/;s/$/"/' ; }

# casepat: generate a case-insensitive pattern
casepat() { perl -pe 's/([a-zA-Z])/sprintf("[%s%s]",uc($1),$1)/ge' ; }

# getcolumn: extract a particular column of space-separated output
# e.g.: lsof | getcolumn 0 | sort | uniq
getcolumn() { perl -ne '@cols = split; print "$cols['$1']\n"' ; }

# cat_pdfs: concatenate PDF files
# e.g. cat_pdfs -o combined.pdf file1.pdf file2.pdf file3.pdf
cat_pdfs() { python '/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py' "$@" ; }

# numberLines: echo the lines of a file preceded by line number
numberLines() { perl -pe 's/^/$. /' "$@" ; }

# convertHex: convert hexadecimal numbers to decimal
convertHex() { perl -ne 'print hex(), "\n"' ; }

# allStrings: show all strings (ASCII & Unicode) in a file
allStrings () { pyg "$1" | tr -d "\0" | strings ; }

# /usr/bin/iconv & /sw/sbin/iconv convert one character encoding to another

# to convert text to HTML and vice vera, use 'textutil'
# to convert a man page to PDF: man -t foo > foo.ps; open foo.ps; save as PDF

#------------
# Processes:
#------------
alias pstree='pstree -g 2 -w'

# findPid: find out the pid of a specified process
#    Note that the command name can be specified via a regex
#    E.g. findPid '/d$/' finds pids of all processes with names ending in 'd'
#    Without the 'sudo' it will only find processes of the current user
findPid() { sudo lsof -t -c "$@" ; }

# to find memory hogs:
alias mem_hogs_top='top -n 10'
alias mem_hogs_ps='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

# to find CPU hogs
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

# continual 'top' listing (every 10 seconds) showing top 15 CPU consumers
alias topforever='top -l 0 -s 10 -o cpu -n 15'

# recommended 'top' invocation to minimize resources in thie macosxhints article
# http://www.macosxhints.com/article.php?story=20060816123853639
# exec /usr/bin/top -R -F -s 10 -o rsize

# diskwho: to show processes reading/writing to disk
alias diskwho='sudo iotop'

psgrep() {
	if [ ! -z $1 ] ; then
		echo "Grepping for processes matching $1..."
		ps aux | grep $1 | grep -v grep
	else
		echo "!! Need name to grep for"
	fi
}

#-----------------------
# Correct common typos:
#-----------------------
alias mann='man'
alias givm='gvim'
alias cta='cat'
alias gerp='grep'
alias sl='ls'
alias hgrp='hgrep'

#------------------------------
# TMUX:
#------------------------------

alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'

# clean up
unset colorflag
unset GREP_OPTIONS
