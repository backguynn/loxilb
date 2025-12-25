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
  echo "llb1: loxicmd create lb 10.10.10.3 --tcp=2020:8080 --endpoints=10.10.10.3:1"
  
  # Try to create LB rule
  if $dexec llb1 loxicmd create lb 10.10.10.3 --tcp=2020:8080 --endpoints=10.10.10.3:1; then
    # Check if hook point exists
    hook=$($dexec llb1 tc filter show dev eth0 ingress | grep tc_packet_func 2>/dev/null || true)
    if [[ $hook == *"tc_packet_func"* ]]; then
      echo "LB rule created successfully with hook point"
      break
    else
      echo "WARNING: LB rule created but no hook point found yet"
      if [ $i -eq 5 ]; then
        echo "ERROR: No hook point found after 5 attempts"
        exit 1
      fi
    fi
  fi
  
  if [ $i -lt 5 ]; then
    echo "Attempt $i failed, retrying in 5 seconds..."
    sleep 5
  else
    echo "Failed to create LB rule after 5 attempts"
    exit 1
  fi
done
