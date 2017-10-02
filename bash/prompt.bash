# heavily inspired by the wonderful pure theme
# https://github.com/sindresorhus/pure

git_dirty() {
    # check if we're in a git repo
    git rev-parse --is-inside-work-tree &>/dev/null || return

    # check if it's dirty
    git diff --quiet --ignore-submodules HEAD &>/dev/null;
    if [ $? -eq 1 ]; then
        echo "${PROMPT_RED}✗"
    else
        echo "${PROMPT_GREEN}✔"
    fi
}

upstream_branch() {
    local remote=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD)) 2>/dev/null
    if [ -n $remote ]; then
        echo "($remote)"
    fi
}

# get the status of the current branch and it's remote
# If there are changes upstream, display a ⇣
# If there are changes that have been committed but not yet pushed, display a ⇡
git_arrows() {
    # do nothing if there is no upstream configured
    git rev-parse --abbrev-ref @'{u}' &>/dev/null || return

    local arrows=""
    local status
    arrow_status="$(command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)"

    # do nothing if the command failed
    (( !$? )) || return

    # split on tabs
    # arrow_status=(${(ps:\t:)arrow_status})
    local left=${arrow_status[1]} 
    local right=${arrow_status[2]}

    (( ${right:-0} > 0 )) && arrows+="⇣"
    (( ${left:-0} > 0 )) && arrows+="⇡"

    echo $arrows
}

parse_git_branch() {
  git branch 2> /dev/null | sed -n '/^\*/s/^\* \(.*\)/git:\[\1\]/p'
}

parse_svn_branch() {
  local svnRootPath=$(svn info . 2>/dev/null | grep -F "Working Copy Root Path:" |  sed -e "s/^Working Copy Root Path:\s*//")
  local svnBranch=""

  if [ -n "$svnRootPath" ]; then
    svnBranch=$(svn info $svnRootPath | grep '^URL: '| sed --regexp-extended -e 's/^(.+)((trunk)|(release.*)|(branch.*))$/\2/g')
    echo "svn:[$svnBranch]"
  fi
}

# indicate a job (for example, vim) has been backgrounded
# If there is a job in the background, display a ✱
suspended_jobs() {
    local sj
    sj=$(jobs 2>/dev/null | tail -n 1)
    if [[ $sj == "" ]]; then
        echo ""
    else
        echo "${PROMPT_WHITE}✱${PROMPT_NORMAL}"
    fi
}

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

# Prompt
# PROMPT_SYMBOL='❯'
# export PROMPT='%(?.%F{207}.%F{160})$PROMPT_SYMBOL%f '
# export RPROMPT='`git_dirty`%F{241}$vcs_info_msg_0_%f`git_arrows``suspended_jobs`'

if [ "$color_prompt" = yes ]; then
    GIT_DIRTY=$(git_dirty)
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    #PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;36m\]\h \[\033[01;34m\]\w \[\033[01;32m\]\$(parse_git_branch)\[\033[m\]\n\$ "
    PS1="${debian_chroot:+($debian_chroot)}${PROMPT_PURPLE}\s"         # \s the name of the shell
    PS1="$PS1 ${PROMPT_L_GRAY}\t"                                      # \t the current time in 24-hour HH:MM:SS format
    PS1="$PS1 ${PROMPT_L_GREEN}\u${PROMPT_WHITE}@${PROMPT_L_CYAN}\h"   # \u the username of the current user
                                                                       # \h the hostname up to the first part
    PS1="$PS1 ${PROMPT_L_BLUE}\w"                                      # \w the current working directory, with $HOME abbreviated with a tilde
    PS1="$PS1 ${PROMPT_L_GREEN}\$(parse_git_branch)${GIT_DIRTY}"
    PS1="$PS1 ${PROMPT_YELLOW}\$(parse_svn_branch)"
    PS1="$PS1 ${PROMPT_WHITE}\$(suspended_jobs)"
    PS1="$PS1 ${PROMPT_NORMAL}\n\$ "                                   # return to system default
                                                                       # \n the newline character
                                                                       # \$ if the effective UID is 0, a #, otherwise a $
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1="${debian_chroot:+($debian_chroot)}\s \t      \u@\h:\w      \$(parse_git_branch) \$(parse_svn_branch) \n\$ "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac