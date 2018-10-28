DIFFTOOL=${GIT_DIFFTOOL:-meld}
alias is-git-repo="git rev-parse --is-inside-work-tree &> /dev/null"

#
# Functions
#
g() {
    if [[ $# > 0 ]]; then
        # if there are arguments, send them to git
        git $@
    else
        # otherwise, run git status
        git status
    fi
}

gs() {
    if [[ $# > 0 ]]; then
        # leave ghostscript alone
        # Ghostscript is an interpreter for PostScript™ and Portable Document Format (PDF) files.
        /usr/bin/gs $@
    else
        # otherwise, run git status --short
        git status --short
    fi
}

gff() { git ls-files | grep $@; }

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
git-current-branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# # The list of remotes
# git-current-repository() {
#   if ! is-git-repo; then
#     return
#   fi
#   echo $(git remote) : $(git remote -v | cut -d':' -f 2)
# }

give-credit() {
    git commit --amend --author $1 <$2> -C HEAD
}

git-unhide-all() {
    git ls-files -v | grep '^h' | sed 's/^..//' | sed 's/\ /\\ /g' | xargs -I FILE git update-index --no-assume-unchanged FILE || true
}

# a simple git rename file function
# git does not track case-sensitive changes to a filename.
git-rename() {
    git mv $1 "${2}-"
    git mv "${2}-" $2
}

gdv() { git diff -w "$@" | view -; }

gipull() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git-current-branch)"
    git pull origin "${b:=$1}"
  fi
}

gipush() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git-current-branch)"
    git push origin "${b:=$1}"
  fi
}

gipushf() {
  [[ "$#" != 1 ]] && local b="$(git-current-branch)"
  git push --force origin "${b:=$1}"
}

git-pull-n-push() {
  if [[ "$#" == 0 ]]; then
    gipull && gipush
  else
    gipull "${*}" && gipush "${*}"
  fi
}

git-rebase-to-remote() {
  [[ "$#" != 1 ]] && local b="$(git-current-branch)"
  git pull --rebase origin "${b:=$1}"
}

# Warn if the current branch is a WIP
git-work-in-progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}

# take this repo and copy it to somewhere else minus the .git stuff.
gitexport() {
    local directory=$1
    local branch=${2:-master}
    mkdir -p "$directory"
    git archive $branch | tar -x -C "$directory"
}

gitwipe() {
    if is-git-repo; then
        rm -rf *
        git checkout .
    fi
}

gdiffstathash() {
  local commits="${1:-HEAD}^..${1:-HEAD}"
  case "$1" in
    --all) commits="";;
  esac
   
  git log --stat --patch $commits
}

gresolveconflict() {
  local strategry=$1
  local pattern=$2
  local file
  local selectedConflictFiles

  if ! is-git-repo; then
    return
  fi

  case "$strategry" in
    t|the*) strategry=theirs;;
    o|our*) strategry=ours;;
    *) echo "Need to specify checkout strategy to be either: (theirs, ours)" && exit -1;;
  esac
  
  selectedConflictFiles=$(git diff --name-only --diff-filter=U)
  [ -n "$pattern" ] && selectedConflictFiles=$(echo $selectedConflictFiles | grep $pattern)

  for file in $selectedConflictFiles; do
    git checkout --$strategry $file
    git add $file
  done
  git commit
}

#
# Git Aliases
# (sorted alphabetically by git-command)
#

# git-add - Add file contents to the index
alias gad='git add'
alias gadd='gad'
alias gada='git add --all'
alias gadp='git add --patch'
alias gadu='git add --update'

# git-bisect - Use binary search to find the commit that introduced a bug
alias gbi='git bisect'
alias gbib='git bisect bad'
alias gbig='git bisect good'
alias gbir='git bisect reset'
alias gbis='git bisect start'

# git-blame - Show what revision and author last modified each line of a file
# -b    Show blank SHA-1 for boundary commits.
# -w    Ignores whitespace changes
alias gbl='git blame -b -w'

# git-branch - List, create, or delete branches
alias gbr='git branch'
alias gbra='git branch -a'
alias gbrd='git branch -d'
alias gbrnm='git branch --no-merged'
alias gbrr='git branch --remote'
alias gbrsup='git branch --set-upstream-to=origin/$(git_current_branch)'

# git-cherry-pick - Apply the changes introduced by some existing commits
alias gchp='git cherry-pick'
alias gchpa='git cherry-pick --abort'
alias gchpc='git cherry-pick --continue'
alias gchpx='git cherry-pick -x' # mark the commit message with cherry-picked hash

# git-clean - Remove untracked files from the working tree
alias gclean='git clean -fd'
alias gcleanhard='git reset --hard && git clean -dfx'

# git-commit - Record changes to the repository
alias gci='git commit -v'
alias gci!='git commit -v --amend'
alias gcin!='git commit -v --no-edit --amend'
alias gcia='git commit -v -a'
alias gcia!='git commit -v -a --amend'
alias gcian!='git commit -v -a --no-edit --amend'
alias gcians!='git commit -v -a -s --no-edit --amend'
alias gciam='git commit -a -m'
alias gcism='git commit -s -m'
# signed commit - need to run `gpg --full-generate-key`
# then need to run `git config --global user.signingkey <key from above>`
# alias gcs='git commit -S'
alias ggci='git gui citool'
alias ggcia='git gui citool --amend'

# git-config - Get and set repository or global options
alias gcfg='git config'
alias gcfgl='git config --list'

# git-checkout - 
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcotheirs='git checkout --theirs'
alias gcoours='git checkout --ours'

# git-fetch - Download objects and refs from another repository
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

# git-log - 
formatShortHash="%h"
formatRefNames="%d"
formatSubject="%s"
formatAuthorName="%an"
formatAuthorDate="%ad"
formatAuthorEmail="%aE"
if ls --color > /dev/null 2>&1; then # GNU `ls`
  formatShortHash="%C(red)$formatShortHash"
  formatRefNames="%C(bold green)$formatRefNames"
  formatSubject="%C(reset)$formatSubject"
  formatAuthorName="%C(bold blue)$formatAuthorName%C(reset)"
  formatAuthorDate="%C(yellow)$formatAuthorDate%C(reset)"
  formatAuthorEmail="%C(green)$formatAuthorEmail%C(reset)"
fi

gitFormatStr="format:'$formatShortHash $formatAuthorDate | $formatRefNames $formatSubject [$formatAuthorName <$formatAuthorEmail>]'"

alias glog="git log"
# quick and simple logs
alias glg='git log --oneline --decorate --abbrev-commit --all'
alias glgr='glg --date=relative'
# equivalent to ls (listing) history
alias glgp="git log --decorate --pretty=$gitFormatStr"
alias gls="glgp --date=short"
alias glr="glgp --date=relative"
alias gll='glgp --numstat'
alias gl1="git ll -1"
# log with diff stat info
alias gstat='git log --stat'
# log with diff
alias glgpatch='git log --patch'
alias gfilelog='glgpatch'
alias gfl="gfilelog"
# log with diff stat info and diff
alias glogdiff='gdiffstathash'
alias gdifflog='gdiffstathash'
# log as a graph
alias gitgraph='git log --graph'
alias ggraphdiff="gitgraph --max-count=10 --stat --patch --abbrev-commit --date=relative --pretty=$gitFormatStr"
# log as a graph on one line
alias ggraph='glg --graph'
alias ghist="gitgraph --abbrev-commit --date=short --pretty=$gitFormatStr"
alias ghistl="gitgraph --abbrev-commit --pretty=$gitFormatStr"
alias ghistr="gitgraph --abbrev-commit --date=relative --pretty=$gitFormatStr"
# show what I did today
alias gday="git log --reverse --no-merges --date=local --after='yesterday 11:59PM' --author=\"`git config --get user.name`\""

alias gmerge='git merge'
alias gmergetheirs='git merge --strategy-option=theirs'
alias gmergeours='git merge --strategy-option=ours'
alias gmergetool="git mergetool --no-prompt --tool=$DIFFTOOL"
alias gmergetoolvim="git mergetool --no-prompt --tool=vimdiff"
alias gmt="gmergetool"

# git-status - 
alias gstatus='git status'
alias gss='git status -s' # also gs with not params/args
alias gssb='git status -sb'

# git-stash - 
alias gsta='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash save'
alias gstshow='git stash show --text'
alias gpop='gstp'
alias gsave='gsts'

#
# in progress below for cleaning up
#
alias gpull='git pull'
alias gpush='git push'
alias gdiff='git diff'
alias gdifftool='git difftool'
alias gdiffc='git diff --cached'
alias gmv='git mv'
alias grm='git rm'
alias grename='git-rename'
alias ghide="git update-index --assume-unchanged"
alias gunhide="git update-index --no-assume-unchanged"
alias gunhideall="git-unhide-all"
alias gundolast='git reset --soft HEAD~1'
alias gcount='git shortlog -sn'
alias gconflict="git diff --name-only --diff-filter=U"
#alias cpbr="git rev-parse --abbrev-ref HEAD | pbcopy"

# git root
alias groot='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'
alias sub-pull='git submodule foreach git pull origin master'

# alias gcl='git clone --recursive'

# alias gd='git diff'
# alias gdca='git diff --cached'
# alias gdcl='git diff --cached HEAD^'
# alias gdt='git diff-tree --no-commit-id --name-only -r'
# alias gdw='git diff --word-diff'

# alias gdct='git describe --tags `git rev-list --tags --max-count=1`'

# alias gk='\gitk --all --branches'
# alias gke='\gitk --all $(git log -g --pretty=%h)'

# alias ggpur='git-rebase-to-remote'

# alias gl='git pull'
# alias ggpull='git pull origin $(git_current_branch)'
# alias gup='git pull --rebase'
# alias gupv='git pull --rebase -v'
# alias glum='git pull upstream master'

# alias ggpush='git push origin $(git_current_branch)'
# alias gpsup='git push --set-upstream origin $(git_current_branch)'
# alias gp='git push'
# alias gpd='git push --dry-run'
# alias gpoat='git push origin --all && git push origin --tags'
# alias gpu='git push upstream'
# alias gpv='git push -v'

# alias gignore='git update-index --assume-unchanged'
# alias gignored='git ls-files -v | grep "^[[:lower:]]"'

# alias grb='git rebase'
# alias grba='git rebase --abort'
# alias grbc='git rebase --continue'
# alias grbi='git rebase -i'
# alias grbm='git rebase master'
# alias grbs='git rebase --skip'

# alias gr='git remote'
# alias gra='git remote add' 
# alias grmv='git remote rename'
# alias grrm='git remote remove'
# alias grset='git remote set-url'
# alias grup='git remote update'
# alias grv='git remote -v'

# alias grt='cd $(git rev-parse --show-toplevel || echo ".")'

# alias grh='git reset HEAD'
# alias grhh='git reset HEAD --hard'
# alias gru='git reset --'

# alias gsd='git svn dcommit'
# alias gsr='git svn rebase'
# alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'

# alias gsi='git submodule init'
# alias gsu='git submodule update'

# alias gsps='git show --pretty=short --show-signature'

# alias gts='git tag -s'
# alias gtv='git tag | sort -V'

# alias gunignore='git update-index --no-assume-unchanged'

# alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

# alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
# alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
 
unset colorflag
unset formatShortHash
unset formatRefNames
unset formatSubject
unset formatAuthorName
unset formatAuthorDate
unset formatAuthorEmail
unset formatMark
unset gitFormatStr