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
for i in {1..5}; do
  echo "Attempting to create LB rule (attempt $i/5)..."
  # Run create_lb_rule in a subshell to prevent exit from terminating the script
  if ( create_lb_rule llb1 10.10.10.3 --tcp=2020:8080 --endpoints=10.10.10.3:1 ); then
    echo "LB rule created successfully"
    break
  fi
  if [ $i -lt 5 ]; then
    echo "Attempt $i failed, retrying in 5 seconds..."
    sleep 5
  else
    echo "Failed to create LB rule after 5 attempts"
    exit 1
  fi
done
