#!/bin/bash

# Variables
JAR_PATH="Tracker-0.0.1-SNAPSHOT.jar"
LOG_PATH="logs.log"
PID_FILE="serverPid.pid"

# Run the JAR file in the background
nohup java -jar $JAR_PATH > $LOG_PATH 2>&1 &
echo $! > $PID_FILE
echo "Java application started with PID $(cat $PID_FILE)"
