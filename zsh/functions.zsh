####################
# functions
####################

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
  if [[ "$OSTYPE" == darwin* ]]; then
    ${=open_cmd} "$@" &>/dev/null
  else
    nohup ${=open_cmd} "$@" &>/dev/null
  fi
}

alias o="open_command"
