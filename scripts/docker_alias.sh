# Aliases Docker
alias mysql-start='~/projetos/docker/scripts/start-mysql.sh'
alias mysql-stop='cd ~/projetos/docker/mysql && docker-compose stop'
alias mysql-logs='cd ~/projetos/docker/mysql && docker-compose logs -f mysql'
alias mysql-connect='docker exec -it shared-mysql mysql -u root -p'