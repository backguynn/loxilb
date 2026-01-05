#!/bin/bash

source ../common.sh

sudo killall -9 loxilb
delete_docker_host llb1

echo "#########################################"
echo "Deleted testbed"
echo "#########################################"
