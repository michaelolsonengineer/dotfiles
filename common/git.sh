# git aliases
alias gadd='git add'
alias gbr='git branch'
alias gpull='git pull'
alias gpush='git push'
alias gdiff='git diff'
alias gdiffc='git diff --cached'
alias gs='git status --short' # sorry GhostScript, but I don't use you
alias gss='git status'
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
#alias cpbr="git rev-parse --abbrev-ref HEAD | pbcopy"

# git root
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

alias sub-pull='git submodule foreach git pull origin master'

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

g() {
    if [[ $# > 0 ]]; then
        # if there are arguments, send them to git
        git $@
    else
        # otherwise, run git status
        git status
    fi
}