# add the git completion from the repo
completion=$DOTFILES/git-completion.bash
if [[ -e $completion ]]; then
    source $completion
fi

# # this is specific to the location of the current version of git, installed by homebrew
# completion=/usr/local/Cellar/git/1.8.0.1/etc/bash_completion.d/git-completion.bash
if [[ -e $completion ]]; then
    source $completion
fi
