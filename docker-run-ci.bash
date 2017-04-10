#!/bin/bash

# {1}: Repository-relative-path to the repository's own CI test script

dir=$(pwd)

docker run -t -v ${dir}:${dir} wavelab/ubuntu:${DOCKER_DISTRO} /bin/bash ${dir}/${1}

if [ $? -ne 0 ]; then
    echo "Docker Run Failed: ${dir}/${1} failed"
    exit 1
fi
