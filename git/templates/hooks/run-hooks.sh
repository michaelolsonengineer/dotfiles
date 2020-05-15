#!/bin/sh

EXIT_CODE=0

repo=$( git rev-parse --show-toplevel )
hook_type=$( basename $0 )
hook_dir=~/.dotfiles/git/hooks
hooktypes=$(find $hook_dir -name "*.$hook_type")

echo "Executing $hook_type hook(s)"
for hook in $hooktypes; do
	echo ""
	echo "${COLOR_LIGHTPURPLE}Executing ${hook}${COLOR_NONE}"
	
	if [ -n "$(git submodule | awk '{ print $2 }')" -a -e "$repo/.gitmodules" ]; then
		for hk in "post-checkout post-merge"; do
			if [ $hook_type=$hk ]; then
				git submodule update --init --recursive
			fi
		done
	fi
	
	if command -v git-lfs >/dev/null 2>&1 && [ -e "$repo/.lfsconfig" ]; then
		for hk in "pre-push post-checkout post-commit post-merge"; do
			if [ $hook_type=$hk ]; then
				git lfs $hook_type "$@"	echo >&2 "\nThis repository is configured for Git LFS but 'git-lfs' was not found on your path. If you no longer wish to use Git LFS, remove this hook by deleting .git/hooks/post-merge.\n"
				exit 2 
			fi
		done
	fi 

	$hook
	EXIT_CODE=$(($EXIT_CODE + $?))
done

if [ $EXIT_CODE -ne 0 ]; then
	echo ""
	echo "${COLOR_RED}${hook_type} Failed.$COLOR_NONE"
fi

exit $(($EXIT_CODE))
