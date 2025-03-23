#!/bin/bash

# Variables
PID_FILE="serverPid.pid"

# Stop the process
if [ -f $PID_FILE ]; then
  PID=$(cat $PID_FILE)
  kill $PID
  echo "Java application with PID $PID stopped"
  rm -f $PID_FILE
else
  echo "PID file not found"
fi
