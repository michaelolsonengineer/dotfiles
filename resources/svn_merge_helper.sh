#!/bin/bash -x
# svn merge-tool wrapper for meld

# Add to ~/.subversion/config
# [helpers]
# merge-tool-cmd = /home/<user>/<path_of_script>/svn-merge-meld.sh
#
# Note that when a conflict occurs, you will be prompted what to do with it.
# You need to type a single 'l' and for svn to run this script. When you've
# finished your merge, you need to type an 'r' to resolve the conflict and copy
# the merged version to the working copy.

base=${1?1st argument is 'base' file}
theirs=${2?2nd argument is 'theirs' file}
mine=${3?3rd argument is 'mine' file}
merged=${4?4th argument is 'merged' file}

# check if running in gui environment
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    /usr/bin/meld --auto-merge \
         --label="Base=${base##*/}"      "$base"   \
         --label="Mine=${mine##*/}"      "$mine"   \
         --label="Theirs=${theirs##*/}"  "$theirs" \
         -o "$merged"

    [ $? -ne 0 ] && echo "Oh noes, an error!"
fi