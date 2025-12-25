#!/bin/bash

source ../common.sh

echo "#########################################"
echo "Spawning all hosts"
echo "#########################################"

spawn_docker_host --dock-type loxilb --dock-name llb1

echo "#########################################"
echo "Connecting and configuring  hosts"
echo "#########################################"

sleep 5

$dexec llb1 ip addr add 10.10.10.3/32 dev lo

sleep 10
create_lb_rule llb1 10.10.10.3 --tcp=2020:8080 --endpoints=10.10.10.3:1
