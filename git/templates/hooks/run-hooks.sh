#!/bin/sh

EXIT_CODE=0

ps1_bold=$(tput bold)
ps1_red=$(tput setaf 1)
ps1_yellow=$(tput setaf 3)
ps1_magenta=$(tput setaf 5)
ps1_cyan=$(tput setaf 6)
ps1_normal=$(tput sgr0)

repo=$( git rev-parse --show-toplevel )
hook_type=$( basename $0 )
hook_dir=~/.dotfiles/git/hooks

# Filter which hook scripts to run by type i.e. post-checkout, post-merge, etc
recent_hooks=$(find $hook_dir -name "recent.$hook_type")
submodule_hooks=$(find $hook_dir -name "submodule.$hook_type")
lfs_hooks=$(find $hook_dir -name "lfs.$hook_type")

echo "──────────────────────────────────────"
echo "${ps1_cyan}Initiated by $hook_type hook${ps1_normal}"

if [ -e "$repo/.gitmodules" ]; then
	for submodule_hook in $submodule_hooks; do
		echo "──────────────────────────────────────"
		echo "${ps1_magenta}Executing ${submodule_hook}${ps1_normal}"
		$submodule_hook
		EXIT_CODE=$(($EXIT_CODE + $?))
	done
fi

if [ -e "$repo/.lfsconfig" ]; then
	for lfs_hook in $lfs_hooks; do
		echo "──────────────────────────────────────"
		echo "${ps1_magenta}Executing ${lfs_hook}${ps1_normal}"
		$lfs_hook
		EXIT_CODE=$(($EXIT_CODE + $?))
	done
fi

for recent_hook in $recent_hooks; do
	echo "──────────────────────────────────────"
	echo "${ps1_magenta}Executing ${recent_hook}${ps1_normal}"
	$recent_hook
	EXIT_CODE=$(($EXIT_CODE + $?))
done

echo "──────────────────────────────────────"

if [ $EXIT_CODE -ne 0 ]; then
	echo "${ps1_red}${hook_type} Failed.$ps1_normal"
else
	echo "${ps1_cyan}$hook_type hook finished.${ps1_normal}"
fi

exit $(($EXIT_CODE))
