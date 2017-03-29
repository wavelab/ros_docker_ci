#!/bin/bash

# {1}: Repository Name
# {2}: Repository-relative-path to the repository's own CI test script

dir=$(pwd)

docker run -t -v ${dir}:/${1} wavelab/ubuntu:${DOCKER_DISTRO} /bin/bash /${1}/${2}

if [ $? -ne 0 ]; then
    echo "Error: ${1} docker run of ${1}/${2} failed"
    exit 1
fi
