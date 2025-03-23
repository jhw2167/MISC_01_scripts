#!/bin/bash

# Check if the first argument (filename) is provided
if [ -z "$1" ]; then
    echo "Provide name of file to transfer as first argument"
    exit 1
fi

scp -i tracker-ec2.pem $1 ec2-user@ec2-100-27-230-138.compute-1.amazonaws.com:/home/ec2-user