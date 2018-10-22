# ssh
export SSH_CONFIG_DIR=$HOME/.ssh
export SSH_KEY_PATH=$SSH_CONFIG_DIR/rsa_id
export SSH_ENV=$SSH_CONFIG_DIR/environment

start_agent() {
  echo "Initializing new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
  echo succeeded
  chmod 600 "$SSH_ENV"
  source "$SSH_ENV" > /dev/null
  /usr/bin/ssh-add;
}

cleanssh() {
  if [ -d "$SSH_CONFIG_DIR" ]; then
    if [ -f $SSH_CONFIG_DIR/known_hosts ]
    then
        echo 'removing SSH known Hosts - printing previous contents'
        cat $SSH_CONFIG_DIR/known_hosts
        rm $SSH_CONFIG_DIR/known_hosts
        echo "$SSH_CONFIG_DIR directory should be cleared - printing its contents"
        ls -la $SSH_CONFIG_DIR
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
