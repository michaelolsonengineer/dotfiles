#!/usr/bin/env python
# svn merge-tool python wrapper for meld
# From: https://stackoverflow.com/questions/7252011/how-to-set-up-svn-conflict-resolution-with-meld
import sys
import subprocess
try:
   # path to meld
   meld = "/usr/bin/meld"
   # file paths
   base   = sys.argv[1]
   theirs = sys.argv[2]
   mine   = sys.argv[3]
   merged = sys.argv[4]

   cmd = [meld, '--auto-merge', mine, base, theirs, '-o', merged]

   # Call meld, making sure it exits correctly
   subprocess.check_call(cmd)
except:
   print "Oh noes, an error!"
   sys.exit(-1)