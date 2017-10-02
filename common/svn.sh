DIFFTOOL=${SVN_DIFFTOOL:-meld}
sstf() { svn status | grep "^$@"; }

# Aliases
alias svnme="svn --username=$SVN_USERNAME"
alias sst="svn status"
alias sstm="sstf 'M'"     # (m)odified
alias ssta="sstf 'A'"     # (a)dded
alias sstd="sstf 'D'"     # (d)eleted
alias sstc="sstf 'C'"     # (c)onflicted
alias sstb="sstf '~'"     # ~ clo(b)bered
alias sstu="sstf '\?'"    # ? (u)nknown
alias ssti="sstf '\!'"    # ! m(i)ssing
alias sadd='svn add'
alias sadda="svn st | grep '^?' | sed 's/^? *\(.*\)/\"\1\"/g' | sed 's/@\(.*\)/@\1@/g' | xargs svn add"
alias srm='svn remove'
alias srma="svn st | grep '^!' | sed 's/^! *\(.*\)/\"\1\"/g' | sed 's/@\(.*\)/@\1@/g' | xargs svn rm"
alias sci='svn commit'
alias sco='svn checkout'
alias sup='svn up'
alias scu='svn cleanup'
alias sli='svn list'
alias sdif="svn diff --diff-cmd=$DIFFTOOL"
alias slog='svn log -l 10'
alias slast='svn log -l 1'
alias smv='svn move'

# alias svnste="svn st --ignore-externals | grep -v '^X' | cut -d: -f2"
# alias svnsti="svn status --ignore-externals | grep \"^?    \""
# alias svnst="echo \"Staged :\" && echo \"-\" && svnste && echo && echo \"Unstaged :\" && echo \"--\" && svnsti"