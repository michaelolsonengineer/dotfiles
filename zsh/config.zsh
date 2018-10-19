setopt no_bg_nice
setopt no_hup
setopt no_list_beep
setopt local_options
setopt local_traps
#setopt ignore_eof

## Set prompt
setopt prompt_subst

setopt interactive_comments

setopt complete_aliases

# Enable command spell checks
setopt correct

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt append_history
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[p" history-beginning-search-backward-end
bindkey "^[n" history-beginning-search-forward-end

# make terminal command navigation sane again
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

fpath=($ZSH/functions $fpath)
autoload -U $ZSH/functions/*(:t)
