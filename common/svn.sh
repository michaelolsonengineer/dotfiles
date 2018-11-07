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
alias sd="svn diff --diff-cmd=$DIFFTOOL"
alias sdif="svn diff -x -b | colordiff"
alias slog='svn log -l 10'
alias slast='svn log -l 1'
alias smv='svn move'

# alias svnste="svn st --ignore-externals | grep -v '^X' | cut -d: -f2"
# alias svnsti="svn status --ignore-externals | grep \"^?    \""
# alias svnst="echo \"Staged :\" && echo \"-\" && svnste && echo && echo \"Unstaged :\" && echo \"--\" && svnsti"

svn_prompt_info() {
  local _DISPLAY
  if in_svn; then
    if [[ "$SVN_SHOW_BRANCH" = true ]]; then
      unset SVN_SHOW_BRANCH
      _DISPLAY=$(svn_get_branch_name)
    else
      _DISPLAY=$(svn_get_repo_name)
      _DISPLAY=$(urldecode "${_DISPLAY}")
    fi
    echo "$PROMPT_BASE_COLOR$SVN_PROMPT_PREFIX\
$REPO_NAME_COLOR$_DISPLAY$PROMPT_BASE_COLOR$SVN_PROMPT_SUFFIX$PROMPT_BASE_COLOR$(svn_dirty)$(svn_dirty_pwd)$PROMPT_BASE_COLOR"
  fi
}


in_svn() {
  svn info ${1:-.} >/dev/null 2>&1
}

svn_get_repo_name() {
  if in_svn; then
    LANG=C svn info | sed -n 's/^Repository\ Root:\ .*\///p' | read SVN_ROOT
    LANG=C svn info | sed -n "s/^URL:\ .*$SVN_ROOT\///p"
  fi
}

# strip root url (relative or otherwise) and svn branch
get_svn_project_name() {
  local input=$1
  local rootUrl=$(svn info --show-item 'repos-root-url' 2> /dev/null)
  [ -z "$input" ] && input=$(svn info --show-item 'relative-url' 2> /dev/null)
  echo $input | \
        sed -e "s,$rootUrl,,"    \
            -e "s,\^/,,"         \
            -e "s,/trunk,,"      \
            -e "s,/releases.*,," \
            -e "s,/branches.*,," \
            -e "s,/tags.*,,"
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

  if [ -z "$_DISPLAY" ]; then
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
  svn_dirty_choose $SVN_PROMPT_DIRTY $SVN_PROMPT_CLEAN
}

svn_dirty_choose() {
  if in_svn; then
    local root=$(LANG=C svn info 2> /dev/null | sed -n 's/^Working Copy Root Path: //p')
    if svn status $root 2> /dev/null | command grep -Eq '^\s*[ACDIM!L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

svn_dirty_pwd () {
  svn_dirty_choose_pwd $SVN_PROMPT_DIRTY_PWD $SVN_PROMPT_CLEAN_PWD
}

svn_dirty_choose_pwd () {
  if in_svn; then
    if svn status "$PWD" 2> /dev/null | command grep -Eq '^\s*[ACDIM!L]'; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

svn_repo_need_upgrade() {
  grep -q "E155036" <<< ${1:-$(svn info 2> /dev/null)} && \
    echo "E155036: upgrade repo with svn upgrade"
}

svn_current_branch_name() {
  grep '^URL:' <<< "${1:-$(svn info 2> /dev/null)}" | egrep -o '(tags|branches)/[^/]+|trunk'
}

svn_repo_root_name() {
  grep '^Repository\ Root:' <<< "${1:-$(svn info 2> /dev/null)}" | sed 's#.*/##'
}

svn_current_revision() {
  echo "${1:-$(svn info 2> /dev/null)}" | sed -n 's/Revision: //p'
}

svn_status_info() {
  local svn_status_string="$SVN_PROMPT_CLEAN"
  local svn_status="$(svn status 2> /dev/null)";
  if command grep -E '^\s*A' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${SVN_PROMPT_ADDITIONS:-+}"; fi
  if command grep -E '^\s*D' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${SVN_PROMPT_DELETIONS:-✖}"; fi
  if command grep -E '^\s*M' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${SVN_PROMPT_MODIFICATIONS:-✎}"; fi
  if command grep -E '^\s*[R~]' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${SVN_PROMPT_REPLACEMENTS:-∿}"; fi
  if command grep -E '^\s*\?' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${SVN_PROMPT_UNTRACKED:-?}"; fi
  if command grep -E '^\s*[CI!L]' &> /dev/null <<< $svn_status; then svn_status_string="$svn_status_string ${SVN_PROMPT_DIRTY:-'!'}"; fi
  echo $svn_status_string
}