# ssh
export SSH_CONFIG_DIR=$HOME/.ssh
export SSH_KEY_PATH=$SSH_CONFIG_DIR/rsa_id
export SSH_ENV=$SSH_CONFIG_DIR/environment

# check if remote ssh session set variable to use going forward
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
  export SESSION_TYPE=remote/ssh
# many other tests omitted
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) export SESSION_TYPE=remote/ssh;;
  esac
fi

start_agent() {
  echo "Initializing new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
  echo succeeded
  chmod 600 "$SSH_ENV"
  source "$SSH_ENV" > /dev/null
  /usr/bin/ssh-add;
}

cleanssh() {
  local sshHomeDir=$SSH_CONFIG_DIR
  local knownHostsDir=$sshHomeDir/known_hosts

  if [ -d "$sshHomeDir" ]; then
    if [ -f "$knownHostsDir" ]; then
        echo 'removing SSH known Hosts - printing previous contents'
        cat $knownHostsDir
        rm $knownHostsDir
        echo "$sshHomeDir directory should be cleared - printing its contents"
        ls -la $sshHomeDir
    else
        echo 'No known ssh hosts'
    fi
  fi
}

# Source SSH settings, if applicable
# Note: `ps ${SSH_AGENT_PID}` doesnt work under cywgin
if [ -f "$SSH_ENV" ]; then
    source "$SSH_ENV" > /dev/null
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ >/dev/null || {
      start_agent;
    }
else
    start_agent;
fi

# Preferred editor for local and remote sessions
case $SESSION_TYPE in
  remote/ssh)
    echo "SSH_CLIENT=$SSH_CLIENT"
    echo "SSH_TTY=$SSH_TTY"
    echo "SSH_CONNECTION=$SSH_CONNECTION"

    export EDITOR='vim'
    export GIT_EDITOR='vim'
  ;;
esac
