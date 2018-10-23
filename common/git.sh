
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

# The list of remotes
git-current-repository() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    return
  fi
  echo $(git remote -v | cut -d':' -f 2)
}

# Pretty log messages
 _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}

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
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git pull origin "${b:=$1}"
  fi
}

gipush() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push origin "${b:=$1}"
  fi
}

gipushf() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
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
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git pull --rebase origin "${b:=$1}"
}

# Warn if the current branch is a WIP
git-work-in-progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}

gitwipe() {
    if git rev-parse --is-inside-work-tree; then
        rm -rf *
        git checkout .
    fi
}

#
# Git Aliases
# (sorted alphabetically-ish)
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

#
# in progress below for cleaning up
#
alias gpull='git pull'
alias gpush='git push'
alias gdiff='git diff'
alias gdiffc='git diff --cached'
alias gss='git status --short'
alias gst='git status'
alias gsave='git stash save'
alias gpop='git stash pop'
alias gmv='git mv'
alias grm='git rm'
alias grename='git-rename'
alias glog="git log"
alias ghide="git update-index --assume-unchanged"
alias gunhide="git update-index --no-assume-unchanged"
alias gunhideall="git-unhide-all"
alias gundolast='git reset --soft HEAD~1'
alias gcount='git shortlog -sn'
alias gconflict="git diff --name-only --diff-filter=U"
#alias cpbr="git rev-parse --abbrev-ref HEAD | pbcopy"

# git root
alias groot='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'
alias is-git-repo="git rev-parse --is-inside-work-tree"
alias sub-pull='git submodule foreach git pull origin master'

# alias gcb='git checkout -b'
# alias gcf='git config --list'
# alias gcl='git clone --recursive'
# alias gclean='git clean -fd'
# alias gpristine='git reset --hard && git clean -dfx'
# alias gcm='git checkout master'
# alias gcd='git checkout develop'
# alias gcmsg='git commit -m'
# alias gco='git checkout'
# alias gcount='git shortlog -sn'

# alias gcp='git cherry-pick'
# alias gcpa='git cherry-pick --abort'
# alias gcpc='git cherry-pick --continue'
# alias gcs='git commit -S'

# alias gd='git diff'
# alias gdca='git diff --cached'
# alias gdct='git describe --tags `git rev-list --tags --max-count=1`'
# alias gdt='git diff-tree --no-commit-id --name-only -r'
# alias gdw='git diff --word-diff'

# alias gf='git fetch'
# alias gfa='git fetch --all --prune'
# alias gfo='git fetch origin'

# alias gg='git gui citool'
# alias gga='git gui citool --amend'

# alias ggpur='git-rebase-to-remote'

# alias ggpull='git pull origin $(git_current_branch)'
# alias ggpush='git push origin $(git_current_branch)'

# alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
# alias gpsup='git push --set-upstream origin $(git_current_branch)'

# alias ghh='git help'

# alias gignore='git update-index --assume-unchanged'
# alias gignored='git ls-files -v | grep "^[[:lower:]]"'
# alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'

# alias gk='\gitk --all --branches'
# alias gke='\gitk --all $(git log -g --pretty=%h)'

# alias gl='git pull'
# alias glg='git log --stat'
# alias glgp='git log --stat -p'
# alias glgg='git log --graph'
# alias glgga='git log --graph --decorate --all'
# alias glgm='git log --graph --max-count=10'
# alias glo='git log --oneline --decorate'
# alias glol="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# alias glola="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
# alias glog='git log --oneline --decorate --graph'
# alias gloga='git log --oneline --decorate --graph --all'
# alias glp="_git_log_prettily"

# alias gm='git merge'
# alias gmom='git merge origin/master'
# alias gmt='git mergetool --no-prompt'
# alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
# alias gmum='git merge upstream/master'

# alias gp='git push'
# alias gpd='git push --dry-run'
# alias gpoat='git push origin --all && git push origin --tags'
# alias gpu='git push upstream'
# alias gpv='git push -v'

# alias gr='git remote'
# alias gra='git remote add'
# alias grb='git rebase'
# alias grba='git rebase --abort'
# alias grbc='git rebase --continue'
# alias grbi='git rebase -i'
# alias grbm='git rebase master'
# alias grbs='git rebase --skip'
# alias grh='git reset HEAD'
# alias grhh='git reset HEAD --hard'
# alias grmv='git remote rename'
# alias grrm='git remote remove'
# alias grset='git remote set-url'
# alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
# alias gru='git reset --'
# alias grup='git remote update'
# alias grv='git remote -v'

# alias gsb='git status -sb'
# alias gsd='git svn dcommit'
# alias gsi='git submodule init'
# alias gsps='git show --pretty=short --show-signature'
# alias gsr='git svn rebase'
# alias gss='git status -s'
# alias gst='git status'
# alias gsta='git stash save'
# alias gstaa='git stash apply'
# alias gstc='git stash clear'
# alias gstd='git stash drop'
# alias gstl='git stash list'
# alias gstp='git stash pop'
# alias gsts='git stash show --text'
# alias gsu='git submodule update'

# alias gts='git tag -s'
# alias gtv='git tag | sort -V'

# alias gunignore='git update-index --no-assume-unchanged'
# alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
# alias gup='git pull --rebase'
# alias gupv='git pull --rebase -v'
# alias glum='git pull upstream master'

# alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
# alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'