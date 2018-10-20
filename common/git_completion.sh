# add the git completion from the repo
completion=$DOTFILES/git-completion.bash

# already sourced if bash through bashrc.
if [ "$CURRENT_SHELL" != "bash" ]; then
    if [[ -e $completion ]]; then
        source $completion
    fi
fi
