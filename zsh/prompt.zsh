# heavily inspired by the wonderful pure theme
# https://github.com/sindresorhus/pure

# needed to get things like current git branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn # You can add hg too if needed: `git hg`
zstyle ':vcs_info:(git|svn)*' use-simple true
zstyle ':vcs_info:(git|svn)*' max-exports 2
zstyle ':vcs_info:(git|svn)*' formats ' %b' 'x%R'
zstyle ':vcs_info:(git|svn)*' actionformats ' %b|%a' 'x%R'

autoload colors && colors

git_dirty() {
    # check if we're in a git repo
    command git rev-parse --is-inside-work-tree &>/dev/null || return

    # check if it's dirty
    command git diff --quiet --ignore-submodules HEAD &>/dev/null;
    if [[ $? -eq 1 ]]; then
        echo "%F{red}✗%f"
    else
        echo "%F{green}✔%f"
    fi
}

upstream_branch() {
    remote=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD)) 2>/dev/null
    if [[ $remote != "" ]]; then
        echo "%F{241}($remote)%f"
    fi
}

# get the status of the current branch and it's remote
# If there are changes upstream, display a ⇣
# If there are changes that have been committed but not yet pushed, display a ⇡
git_arrows() {
    # do nothing if there is no upstream configured
    command git rev-parse --abbrev-ref @'{u}' &>/dev/null || return

    local arrows=""
    local status
    arrow_status="$(command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)"

    # do nothing if the command failed
    (( !$? )) || return

    # split on tabs
    arrow_status=(${(ps:\t:)arrow_status})
    local left=${arrow_status[1]} right=${arrow_status[2]}

    (( ${right:-0} > 0 )) && arrows+="%F{011}⇣%f"
    (( ${left:-0} > 0 )) && arrows+="%F{012}⇡%f"

    echo $arrows
}

# vim:ft=zsh ts=2 sw=2 sts=2 et
#
# Faster alternative to the current SVN plugin implementation.
#
# Works with svn 1.6, 1.7, 1.8.
# Use `svn_prompt_info` method to enquire the svn data.
# It's faster because his efficient use of svn (single svn call) which saves a lot on a huge codebase
# It displays the current status of the local files (added, deleted, modified, replaced, or else...)
#
# Use as a drop-in replacement of the svn plugin not as complementary plugin
svn_prompt_info() {
  local info
  info=$(svn info 2>&1) || return 1; # capture stdout and stderr
  local repo_need_upgrade=$(svn_repo_need_upgrade $info)

  if [ -n $repo_need_upgrade ]; then
    printf '%s%s%s%s%s%s%s\n' \
      $PROMPT_BASE_COLOR \
      $SVN_PROMPT_PREFIX \
      $PROMPT_BASE_COLOR \
      $repo_need_upgrade \
      $PROMPT_BASE_COLOR \
      $SVN_PROMPT_SUFFIX \
      $PROMPT_BASE_COLOR
  else
    printf '%s%s%s %s%s:%s%s%s%s%s' \
      $PROMPT_BASE_COLOR \
      $SVN_PROMPT_PREFIX \
      \
      "$(svn_status_info $info)" \
      $PROMPT_BASE_COLOR \
      \
      $BRANCH_NAME_COLOR \
      $(svn_current_branch_name $info) \
      $PROMPT_BASE_COLOR \
      \
      $(svn_current_revision $info) \
      $PROMPT_BASE_COLOR \
      \
      $SVN_PROMPT_SUFFIX \
      $PROMPT_BASE_COLOR
  fi
}

prompt_svn() {
    local rev branch
    if in_svn; then
        rev=$(svn_get_rev_nr)
        branch=$(svn_get_branch_name)
        if [[ $(svn_dirty_choose_pwd 1 0) -eq 1 ]]; then
            prompt_segment yellow black
            echo -n "$rev@$branch"
            echo -n "±"
        else
            prompt_segment green black
            echo -n "$rev@$branch"
        fi
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
        echo "%{$FG[208]%}✱%f"
    fi
}

case $TERM in
  xterm*)
    precmd () {
      vcs_info
      print -P "\e]0;zsh- %n@%m: %~\a\n%F{153}%n%F{255}@%F{192}%m%F{255}:%F{6}%~"
    }
    ;;
esac

PROMPT_SYMBOL='❯'

export PROMPT='%(?.%F{207}.%F{160})$PROMPT_SYMBOL%f '
export RPROMPT='`git_dirty`%F{221}$vcs_info_msg_0_%f`git_arrows``suspended_jobs`'

# build_prompt() {
#     RETVAL=$?
#     prompt_status
#     prompt_context
#     prompt_dir
#     prompt_git
#     prompt_svn
#     prompt_end
# }