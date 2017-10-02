DIFFTOOL=${SVN_DIFFTOOL:-meld}
alias sd="svn diff --diff-cmd=$DIFFTOOL"
alias svnme="svn --username=$SVN_USERNAME"
alias svnstat="svn status | grep '^M'"
alias sst="svn status | grep '^M'"