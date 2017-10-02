svn_prompt_info() {
  local _DISPLAY
  if in_svn; then
    if [[ "$SVN_SHOW_BRANCH" = true ]]; then
      unset SVN_SHOW_BRANCH
      _DISPLAY=$(svn_get_branch_name)
    else
      _DISPLAY=$(svn_get_repo_name)
      _DISPLAY=$(omz_urldecode "${_DISPLAY}")
    fi
    echo "$ZSH_PROMPT_BASE_COLOR$ZSH_THEME_SVN_PROMPT_PREFIX\
$ZSH_THEME_REPO_NAME_COLOR$_DISPLAY$ZSH_PROMPT_BASE_COLOR$ZSH_THEME_SVN_PROMPT_SUFFIX$ZSH_PROMPT_BASE_COLOR$(svn_dirty)$(svn_dirty_pwd)$ZSH_PROMPT_BASE_COLOR"
  fi
}


in_svn() {
  svn info >/dev/null 2>&1
}

svn_get_repo_name() {
  if in_svn; then
    LANG=C svn info | sed -n 's/^Repository\ Root:\ .*\///p' | read SVN_ROOT
    LANG=C svn info | sed -n "s/^URL:\ .*$SVN_ROOT\///p"
  fi
}

svn_get_branch_name() {
  local _DISPLAY=$(
    LANG=C svn info 2> /dev/null | \
      awk -F/ \
      '/^URL:/ { \
        for (i=0; i<=NF; i++) { \
          if ($i == "branches" || $i == "tags" ) { \
            print $(i+1); \
            break;\
          }; \
          if ($i == "trunk") { print $i; break; } \
        } \
      }'
  )

  if [[ -z "$_DISPLAY" ]]; then
    svn_get_repo_name
  else
    echo $_DISPLAY
  fi
}

svn_get_rev_nr() {
  if in_svn; then
    LANG=C svn info 2> /dev/null | sed -n 's/Revision:\ //p'
  fi
}

svn_dirty() {
  svn_dirty_choose $ZSH_THEME_SVN_PROMPT_DIRTY $ZSH_THEME_SVN_PROMPT_CLEAN
}

svn_dirty_choose() {
  if in_svn; then
    local root=$(LANG=C svn info 2> /dev/null | sed -n 's/^Working Copy Root Path: //p')
    if svn status $root 2> /dev/null | command grep -Eq '^\s*[ACDIM!?L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

svn_dirty_pwd () {
  svn_dirty_choose_pwd $ZSH_THEME_SVN_PROMPT_DIRTY_PWD $ZSH_THEME_SVN_PROMPT_CLEAN_PWD
}

svn_dirty_choose_pwd () {
  if in_svn; then
    if svn status "$PWD" 2> /dev/null | command grep -Eq '^\s*[ACDIM!?L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
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

function svn_prompt_info() {
  local info
  info=$(svn info 2>&1) || return 1; # capture stdout and stderr
  local repo_need_upgrade=$(svn_repo_need_upgrade $info)

  if [[ -n $repo_need_upgrade ]]; then
    printf '%s%s%s%s%s%s%s\n' \
      $ZSH_PROMPT_BASE_COLOR \
      $ZSH_THEME_SVN_PROMPT_PREFIX \
      $ZSH_PROMPT_BASE_COLOR \
      $repo_need_upgrade \
      $ZSH_PROMPT_BASE_COLOR \
      $ZSH_THEME_SVN_PROMPT_SUFFIX \
      $ZSH_PROMPT_BASE_COLOR
  else
    printf '%s%s%s %s%s:%s%s%s%s%s' \
      $ZSH_PROMPT_BASE_COLOR \
      $ZSH_THEME_SVN_PROMPT_PREFIX \
      \
      "$(svn_status_info $info)" \
      $ZSH_PROMPT_BASE_COLOR \
      \
      $ZSH_THEME_BRANCH_NAME_COLOR \
      $(svn_current_branch_name $info) \
      $ZSH_PROMPT_BASE_COLOR \
      \
      $(svn_current_revision $info) \
      $ZSH_PROMPT_BASE_COLOR \
      \
      $ZSH_THEME_SVN_PROMPT_SUFFIX \
      $ZSH_PROMPT_BASE_COLOR
  fi
}

function svn_repo_need_upgrade() {
  grep -q "E155036" <<< ${1:-$(svn info 2> /dev/null)} && \
    echo "E155036: upgrade repo with svn upgrade"
}

function svn_current_branch_name() {
  grep '^URL:' <<< "${1:-$(svn info 2> /dev/null)}" | egrep -o '(tags|branches)/[^/]+|trunk'  
}

function svn_repo_root_name() {
  grep '^Repository\ Root:' <<< "${1:-$(svn info 2> /dev/null)}" | sed 's#.*/##'
}

function svn_current_revision() {
  echo "${1:-$(svn info 2> /dev/null)}" | sed -n 's/Revision: //p'
}

function svn_status_info() {
  local svn_status_string="$ZSH_THEME_SVN_PROMPT_CLEAN"
  local svn_status="$(svn status 2> /dev/null)";
  if command grep -E '^\s*A' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${ZSH_THEME_SVN_PROMPT_ADDITIONS:-+}"; fi
  if command grep -E '^\s*D' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${ZSH_THEME_SVN_PROMPT_DELETIONS:-✖}"; fi
  if command grep -E '^\s*M' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${ZSH_THEME_SVN_PROMPT_MODIFICATIONS:-✎}"; fi
  if command grep -E '^\s*[R~]' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${ZSH_THEME_SVN_PROMPT_REPLACEMENTS:-∿}"; fi
  if command grep -E '^\s*\?' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${ZSH_THEME_SVN_PROMPT_UNTRACKED:-?}"; fi
  if command grep -E '^\s*[CI!L]' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${ZSH_THEME_SVN_PROMPT_DIRTY:-'!'}"; fi
  echo $svn_status_string
}