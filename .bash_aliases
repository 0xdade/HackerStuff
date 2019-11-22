alias tcheck="curl -s https://check.torproject.org | cat | grep -m 1 Congratulations | xargs"
alias icanhazip="curl icanhazip.com"
alias newnym="sudo service tor restart"
alias docker_clean_images='sudo docker rmi $(sudo docker images -a --filter=dangling=true -q)'
alias docker_clean_containers='sudo docker rm $(sudo docker ps --filter=status=exited --filter=status=created -q)'
