
export CURRENT_SHELL=$(ps -p $$ | awk '$1 == PP {print $4}' PP=$$)

if [ "$CURRENT_SHELL" = "bash" ]; then
   alias reshell="source ${HOME}/.bashrc"
elif [ "$CURRENT_SHELL" = "zsh" ]; then
   alias reshell="source ${HOME}/.zshrc"
elif [ "$CURRENT_SHELL" = "ash" ]; then
   alias reshell="source ${HOME}/.ashrc"
fi

alias ralias='. ${HOME}/.aliases.sh'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color=auto"
else # OS X `ls`
    colorflag="-G"
fi

alias open='xdg-open'

alias svnstat="svn status | grep '^M'"

alias kitten='pygmentize -g'

# Alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#####

#alias fullmake='make clean; make DEBUG=-g CCOPTS=-O0 MAKEFLAGS+=-j${NUMBER_OF_PROCESSORS} install'

alias svnmelddiff='svn diff --diff-cmd="meld"'
alias sd='svn diff --diff-cmd=meld'

alias grp='grep -rI --color --exclude-dir=\.bzr --exclude-dir=\.git --exclude-dir=\.hg --exclude-dir=\.svn --exclude-dir=build --exclude-dir=dist --exclude=tags --exclude-dir=nto --exclude-dir=arm --exclude=cscope.out --exclude=cctree.out --exclude=\*.{0,1,2,js} $*'

alias c='clear'

alias grep="grep $colorflag"
alias fgrep="fgrep $colorflag"
alias egrep="egrep $colorflag"

## Colorize the ls output ##
alias ls="ls $colorflag"

## Use long listing format ##
alias ll="ls -alF $colorflag"
alias la="ls -A $colorflag"
alias l="ls -CF $colorflag"

## Show hidden files ##
alias l.="ls -d .* $colorflag"
alias lld="ls -l | grep ^d $colorflag"

## get rid of command not found ##
alias cd..='cd ..'

## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

alias bc='bc -l'

# install  colordiff package :)
alias diff='colordiff'

# handy short cuts #
alias h='history'
alias j='jobs -l'

alias path=`echo -e ${PATH//:/\\n}`
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Set vim as default
alias vi='vim'
alias svi='sudo vi'
alias vis='vim "+set si"'
alias edit='subl'

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
	sudo chown -R ${USER} ${1:-.}
}

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
	echo "--------------- Network Information ---------------"
	/sbin/ifconfig | awk /'inet addr/ {print $2}'
	/sbin/ifconfig | awk /'Bcast/ {print $3}'
	/sbin/ifconfig | awk /'inet addr/ {print $4}'
	/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
	myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
	echo "${myip}"
	echo "---------------------------------------------------"
}

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
alias nfsrestart='sync && sleep 2 && /etc/init.d/httpd stop && umount netapp2:/exports/http && sleep 2 && mount -o rw,sync,rsize=32768,wsize=32768,intr,hard,proto=tcp,fsc natapp2:/exports /http/var/www/html &&  /etc/init.d/httpd start'


#Grabs the disk usage in the current directory
#alias usage='du -ch | grep total'
alias usage='du -ch 2> /dev/null |tail -1'
#Gets the total disk usage on your machine
alias totalusage='df -hl --total | grep total'
#Shows the individual partition usages without the temporary memory values
alias partusage='df -hlT --exclude-type=tmpfs --exclude-type=devtmpfs'
#Gives you what is using the most space. Both directories and files. Varies on
#current directory
alias most='du -hsx * | sort -rh | head -10'
# shoot the fat ducks in your current dir and sub dirs
alias ducks='du -ck | sort -nr | head'
#
alias mosthome='du -ah /home 2>/dev/null | sort -hr | head -n 10'


alias up1="cd .."
# edit multiple files split horizontally or vertically
alias e="vim -o "
alias E="vim -O "
# directory-size-date (remove the echo/blank line if you desire)
alias dsd="echo;ls -Fla"
alias dsdm="ls -FlAh | more"
# show directories only
alias dsdd="ls -FlA | grep :*/"
# show executables only
alias dsdx="ls -FlA | grep \*"
# show non-executables
alias dsdnx="ls -FlA | grep -v \*"
# order by date
alias dsdt="ls -FlAtr "
# dsd plus sum of file sizes
alias dsdz="ls -Fla $1 $2 $3 $4 $5  | awk '{ print; x=x+\$5 } END { print \"total bytes = \",x }'"
# only file without an extension
alias noext='dsd | egrep -v "\.|/"'
# send pwd to titlebar in puttytel
alias ttb='echo -ne "33]0;`pwd`07"'
# send parameter to titlebar if given, else remove certain paths from pwd
alias ttbx="titlebar"
# titlebar
if [ $# -lt 1 ]
then
    ttb=`pwd | sed -e 's+/projects/++' -e 's+/project01/++' -e 's+/project02/++' -e 's+/export/home/++' -e 's+/home/++'`
else
    ttb=$1
fi
#echo -ne "33]0;`echo $ttb`07"
alias machine="echo you are logged in to ... `uname -a | cut -f2 -d' '`"
alias info='clear;machine;pwd'

alias clearx="echo -e '\\0033\\0143'"
alias clear='printf "\\033c"'

alias g='git'
alias gr='git rm -rf'
alias gs='git status'
alias ga='g add'
alias gc='git commit -m'
alias gp='git push origin master'
alias gl='git pull origin master'

#------------
# Subversion
#------------
svnDir=~/svn

# svnco: checkout a project from Subversion to the current directory
svnco () { svn co $SVN_MIRROR/$1/trunk ${1//\//_} ; }

# svndiff: diff of current file with Subversion repository
alias sd='svn diff --diff-cmd=meld'

# svnci: check in a file or directory to Subversion (will prompt for comments)
alias svnci='svn ci'


#-------------------------
# C/C++/Java Programming:
#-------------------------
# indent: C-program formatter
alias indent='indent -st'

# to find what symbols are pre-defined by the compiler
# Note that this can be done simpler via: /usr/bin/gcc -E -dM /dev/null
gcc_defines() { tmpfile="/tmp/foo$$.cpp"; echo "int main(){return 0;}" > $tmpfile; /usr/bin/gcc -E -dM $tmpfile; rm $tmpfile ; }

# count lines of java code under the current directory
alias count_java='find . -name "*.java" -print0 | xargs -0 wc'

# count lines of C or C++ or Obj-C code under the current directory
alias count_c='find . \( -name "*.c" -or -name "*.cpp" -or -name "*.h" -or -name "*.m" \) -print0 | xargs -0 wc'

# count lines of C or C++ or Obj-C or Java code under the current directory
alias count_loc='find . \( -name "*.c" -or -name "*.cpp" -or -name "*.h" -or -name "*.m" -or -name "*.java" \) -print0 | xargs -0 wc'

# to do search & replace in programming code - use 'tops'


#-------------------
# Perl programming:
#-------------------
# cpan: run Perl's CPAN module to get updates
alias cpan='sudo perl -MCPAN -e shell'

# testmod: test to see if a Perl module is installed. Sample usage: testmod LWP
# a possible alternative implemention: perldoc -l \!*
testmod() { perl -e "use $@" ; }

# viperl: use vi to edit a file in ~/Dev/Perl
viperl() { /usr/bin/vi ~/Dev/Perl/"$@" ; }

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


#-----------
# Searching:
#-----------
# ff:  to find a file under the current directory
ff() { /usr/bin/find . -name "$@" ; }
# ffs: to find a file whose name starts with a given string
ffs() { /usr/bin/find . -name "$@"'*' ; }
# ffe: to find a file whose name ends with a given string
ffe() { /usr/bin/find . -name '*'"$@" ; }

# grepfind: to grep through files found by find, e.g. grepf pattern '*.c'
# note that 'grep -r pattern dir_name' is an alternative if want all files
grepfind() {
	[ -z "$3" ] && find . -type f -name "$2" -print0 | xargs -0 grep -n "$1" | awk '!/.svn/' ;
    [ -n "$3" ] && find "$3" -type f -name "$2" -print0 | xargs -0 grep -n "$1" | awk '!/.svn/' ;
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
findword() { /usr/bin/grep ^"$@"$ /usr/share/dict/words ; }

# dict: lookup a word with Dictionary.app
dict() { open dict:///"$@" ; }


#---------------
# Text handling:
#---------------
# fixlines: edit files in place to ensure Unix line-endings
fixlines() { /usr/bin/perl -pi~ -e 's/\r\n?/\n/g' "$@" ; }

# cut80: truncate lines longer than 80 characters (for use in pipes)
alias cut80='/usr/bin/cut -c 1-80'

# foldpb: make text in clipboard wrap so as to not exceed 80 characters
alias foldpb='pbpaste | fold -s | pbcopy'

# enquote: surround lines with quotes (useful in pipes) - from mervTormel
enquote() { /usr/bin/sed 's/^/"/;s/$/"/' ; }

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
allStrings () { cat "$1" | tr -d "\0" | strings ; }

# /usr/bin/iconv & /sw/sbin/iconv convert one character encoding to another

# to convert text to HTML and vice vera, use 'textutil'
# to convert a man page to PDF: man -t foo > foo.ps; open foo.ps; save as PDF


#------------
# Processes:
#------------
alias pstree='/sw/bin/pstree -g 2 -w'

# findPid: find out the pid of a specified process
#    Note that the command name can be specified via a regex
#    E.g. findPid '/d$/' finds pids of all processes with names ending in 'd'
#    Without the 'sudo' it will only find processes of the current user
findPid() { sudo lsof -t -c "$@" ; }

# to find memory hogs:
alias mem_hogs_top='top -l 1 -o rsize -n 10'
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

#--------------------------
# File & folder management:
#--------------------------
# various 'ls' shortcuts
#function ll ()  { /bin/ls -aOl "$@" | /usr/bin/more ; }
#function lll () { /bin/ls -aOle "$@" | /usr/bin/more ; }
#function lt ()  { /bin/ls -lt "$@" | /usr/bin/more ; }
#function lsr () { /bin/ls -l "$@"/..namedfork/rsrc ; }

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
zipf() { zip -r "$1".zip "$1" ; }

# numFiles: number of (non-hidden) files in current directory
alias numFiles='echo $(ls -1 | wc -l)'

# showTimes: show the modification, metadata-change, and access times of a file
showTimes() { stat -f "%N:   %m %c %a" "$@" ; }

#--------------------------------------------
# Aliases and this file:
#--------------------------------------------
# showa: to remind yourself of an alias (given some part of it)
showa() { grep -i -a1 $@ ~/.aliases.sh | grep -v '^\s*$' ; }

# sourcea: to source this file (to make changes active after editing)
alias sourcea='source ~/.aliases.sh'


#-----------------------
# Correct common typos:
#-----------------------
alias mann='man'

#------------------------------
# Terminal & shell management:
#------------------------------
# fix_stty: restore terminal settings when they get completely screwed up
alias fix_stty='stty sane'

# cic: make tab-completion case-insensitive
alias cic='set completion-ignore-case On'

# show_options: display bash options settings
alias show_options='shopt'

alias acking='ACK_PAGER_COLOR="less -x4SRFX" /usr/bin/ack-grep -a'

# # GDB scripts
# alias currentgdb="~/current/p4/deckard-65x/developer/trunk/host/linux/x86/usr/bin/ntoarm-gdb"

# # BDT shortcuts
# alias bdtlogs='bdt.py -CLI --run="Extract Logs"'
# alias bdttracelogger='bdt.py -CLI --run="Tracelogger Tools"'
# alias bdtwebsl='bdt.py -CLI --run="OTA WebSL Change Tool"'
# alias bdtmount='bdt.py -CLI --run="Remote File Access"'
# alias bdtfileaccess='bdt.py -CLI --run="Remote File Access"'
# alias bdtnfs='bdt.py -CLI --run="Remote File Access"'
# alias bdtscreen='bdt.py -CLI --run="Screen Capturing"'
# alias bdtshell='bdt.py -CLI --run="Remote Shell Terminal"'
# alias bdtbar='bdt.py -CLI --run="Application BAR Tools"'
# alias bdtgui='bdt.py -GUI'

# # QDT shortcuts
# alias qdtlogs='qdt.py -CLI --run="Extract Logs"'
# alias qdttracelogger='qdt.py -CLI --run="Tracelogger Tools"'
# alias qdtwebsl='qdt.py -CLI --run="OTA WebSL Change Tool"'
# alias qdtmount='qdt.py -CLI --run="Remote File Access"'
# alias qdtscreen='qdt.py -CLI --run="Screen Capturing"'
# alias qdtshell='qdt.py -CLI --run="Remote Shell Terminal"'

# # set environment aliases
# alias setdev='cd ~/p4/branches/main/ws2/ap/msm && . setenv.sh qct && cd -'
# alias setbranch='cd ~/p4/branches/BB10_2_0X/ws3/ap/msm && . setenv.sh qct && cd -'
# alias setqct='cd ~/current/p4 && . setenv.sh qct && cd -'
# alias setqnx='cd ~/current/p4 && . setenv.sh common && cd -'
# alias setp4='cd ~/current/p4 && . setenv.sh qct && cd -'
# alias setcommon='cd ~/current/p4 && . setenv.sh common && cd -'


# alias gosetdev='cd ~/p4/branches/main/ws2/ap/msm && . setenv.sh qct'
# alias gosetbranch='cd ~/p4/branches/BB10_2_0X/ws3/ap/msm  && . setenv.sh qct'
# alias gosetqct='cd ~/current/p4 && . setenv.sh qct'
# alias gosetqnx='cd ~/current/p4 && . setenv.sh common'

# # Location aliases
# alias godev='cd ~/p4/branches/main/ws2/ap/msm'
# alias gobranch='cd ~/p4/branches/BB10_2_0X/ws3/ap/msm'
# alias gocurrent='cd ~/current'
# alias gop4='cd ~/p4'
# alias goblue='cd ~/current/p4 && . setenv.sh common && cd ~/current/svn/bluetooth_qnx'
# alias goaudio='cd ~/current/p4 && . setenv.sh common && cd ~/current/svn/audio_qnx'
# alias gomisc='cd ~/current/p4 && . setenv.sh common && cd ~/current/svn/miscellaneous_qnx'

# #grep -i "169.254" ~/tmp/bb10ip.dat -A7 -B1
# #cat /var/lib/dhcp/dhclient--usb0.lease
# #grep -i "inet addr" ~/tmp/bb10ip.dat
# #sed "s/^.*: //g" ~/tmp/bb10ip.dat

# tempvar=`ifconfig -a`
# for v in $tempvar; do echo $v | grep addr:169.254; done > ~/tmp/BB10IP_temp.dat
# tempvar=`cat ~/tmp/BB10IP_temp.dat`
# IFS=":"; for v in $tempvar; do echo $v | grep 169.254; done > ~/tmp/BB10IP_temp.dat
# IFS=" "
# tempvar=`sed 's/\(169.254.[0-9]*.\)\([0-9]*\)/\2/' ~/tmp/BB10IP_temp.dat | awk '{dec=$1-1} END {print dec}'`
# tempvar=`sed 's/\(169.254.[0-9]*.\)\([0-9]*\)/\1'$tempvar'/' ~/tmp/BB10IP_temp.dat`
# export BB_ADR=$tempvar
# rm ~/tmp/BB10IP_temp.dat

# alias bbip="export BB_ADR=$(getBBIP)"
# alias bbtelnet="export BB_ADR=$(getBBIP); telnet $BB_ADR"
# alias bbftp="filezilla root:root@$BB_ADR &"
# #alias bbftp="export BB_ADR=`getBBIP`; filezilla root:root@$BB_ADR"

# alias bbssh="bbip; ssh root@$BB_ADR"
# alias bbsshpd="bbip; sshpass -p 'root' ssh root@$BB_ADR"
# alias sshjenkins="sshpass -p 'password' ssh jenkins@opias.openpeak.com"


