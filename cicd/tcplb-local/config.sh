#!/bin/bash

source ../common.sh

echo "#########################################"
echo "Spawning all hosts"
echo "#########################################"

spawn_docker_host --dock-type loxilb --dock-name llb1 --extra-args "--localsockpolicy"

echo "#########################################"
echo "Connecting and configuring  hosts"
echo "#########################################"

sleep 5

$dexec llb1 ip addr add 10.10.10.3/32 dev lo

sleep 5

# Check if loxilb is running
echo "Checking if loxilb is running..."
if ! $dexec llb1 pgrep -f "/root/loxilb-io/loxilb/loxilb" > /dev/null 2>&1; then
  echo "loxilb is not running, starting manually..."
  echo "Starting loxilb with output visible..."
  
  # Start loxilb in background but with output captured
  $dexec llb1 /root/loxilb-io/loxilb/loxilb 2>&1 | tee /tmp/loxilb_manual.log &
  LOXILB_PID=$!
  
  # Wait for loxilb to be ready (check for process)
  echo "Waiting for loxilb to start..."
  for i in {1..30}; do
    if $dexec llb1 pgrep -f "/root/loxilb-io/loxilb/loxilb" > /dev/null 2>&1; then
      echo "loxilb started successfully (attempt $i)"
      break
    fi
    if [ $i -eq 30 ]; then
      echo "ERROR: loxilb failed to start after 30 seconds"
      echo "== Process status =="
      $dexec llb1 ps aux
      echo "== Manual loxilb log =="
      cat /tmp/loxilb_manual.log 2>/dev/null || echo "No log available"
      exit 1
    fi
    sleep 1
  done
  
  # Additional wait for API to be ready
  sleep 5
else
  echo "loxilb is already running"
fi

create_lb_rule llb1 10.10.10.3 --tcp=2020:8080 --endpoints=10.10.10.3:1
