# matches case insensitive for lowercase
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# default to file completion
zstyle ':completion:*' completer _list _expand _complete _ignored _correct _approximate _files

if [[ "$OSTYPE" == darwin* ]]; then
	# this is specific to the location of the current version of git, installed by homebrew
	completion=/usr/local/Cellar/git/1.8.0.1/etc/bash_completion.d/git-completion.bash

	if test -f $completion; then
	    source $completion
	fi
fi

zstyle :compinstall filename "$HOME/.zshrc"

# initialize autocomplete
autoload -Uz compinit
compinit
