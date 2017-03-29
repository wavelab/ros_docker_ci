#!/bin/bash
set -e

mkdir -p ${DOCKER_CACHE_DIR}

if [[ -f ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz ]]; then
    echo "${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz already exists. No need to re-write."
else
    echo "${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz not found."

    echo "Saving docker image to ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz..."
    docker save "wavelab/ubuntu:${DOCKER_DISTRO}" | gzip -2 > ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz
fi
