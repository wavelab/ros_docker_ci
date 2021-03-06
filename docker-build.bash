#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp -r $(pwd)/scripts ${DIR}/${1}/scripts

docker build -t wavelab/ubuntu:${1} ${DIR}/${1}

RES=$?

rm -r ${DIR}/${1}/scripts

if [ ${RES} -ne 0 ]; then
    echo "Error: ${1} docker build failed"
    exit 1
fi
