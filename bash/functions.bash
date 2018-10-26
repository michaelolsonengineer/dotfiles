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
