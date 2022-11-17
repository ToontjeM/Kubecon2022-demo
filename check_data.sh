#!/bin/bash
. ./config.sh
printf "${green}kubectl exec -it $1-1 -- psql -c 'select count(*) from test;'${reset}\n"

kubectl exec -it $1-1 -- psql -c "select count(*) from test;"
