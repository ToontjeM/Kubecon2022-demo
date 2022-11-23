#!/bin/bash
. ./config.sh
printf "${green}kubectl delete pod cluster-example-1 --force${reset}\n"

kubectl delete pod cluster-example-1 --force
